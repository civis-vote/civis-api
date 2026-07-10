# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'database_cleaner'
require 'faker'

puts "Cleaning the database ...\n"
DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

puts '---> Importing Ministry Categories'
Rake::Task['import_records_from_array:ministry_categories'].invoke('')
Rake::Task['import_records_from_array:ministry_categories'].reenable

puts '---> Importing Locations'
Rake::Task['import_records_from_csv:locations'].invoke('')
Rake::Task['import_records_from_csv:locations'].reenable

puts '---> Importing Point Scale'
Rake::Task['import_records_from_csv:point_scale'].invoke('')
Rake::Task['import_records_from_csv:point_scale'].reenable

puts '---> Fabricating API Team'
Fabricate(:user, email: 'mkv@commutatus.com', role: 'admin')
Fabricate(:user, email: 'balaji@commutatus.com', role: 'admin')

puts '---> Fabricating 50 categories'
progressbar = ProgressBar.create
50.times do
  Fabricate(:category)
  progressbar.increment
end

puts '---> Fabricating 50 ministries'
progressbar = ProgressBar.create
50.times do
  Fabricate(:ministry)
  progressbar.increment
end

puts '---> Fabricating 50 users'
progressbar = ProgressBar.create
50.times do
  Fabricate(:user)
  progressbar.increment
end

puts '---> Fabricating 10 consultations'
progressbar = ProgressBar.create
50.times do
  Fabricate(:consultation)
  progressbar.increment
end

puts '---> Publish some consultations'
Consultation.where(status: :submitted).order('RANDOM()').limit(30).each do |consultation|
	 consultation.publish
end

puts '---> Reject some consultations'
Consultation.where(status: :submitted).order('RANDOM()').limit(10).each do |consultation|
	 consultation.reject
end

puts '---> Expire some consultations'
Consultation.where(status: :published).order('RANDOM()').limit(10).each do |consultation|
	 consultation.expire
end

puts '---> Responding to some consultations'
Consultation.where(status: %i[published rejected]).each do |consultation|
	 response_count = [0, 1, 2, 3, 4, 5].sample
	 Fabricate.times(response_count, :response_round, consultation_id: consultation.id)
	 begin
 		 puts '---> Creating Response Round for consultations'
  		Fabricate.times(response_count, :consultation_response, consultation_id: consultation.id, response_round_id: consultation.response_rounds.last.id)
  rescue ActiveRecord::RecordInvalid => e
  		puts "---> #{e.record.errors.full_messages.join('\n')}"
 	end
end

puts '---> Creating Question to consultation'
Fabricate.times(10, :question)
Question.all.each do |question|
	 puts '---> Creating sub questions'
	 Fabricate.times(4, :question, parent_id: question.id)
end

puts '---> Creating Organisation and employees'
Fabricate.times(5, :organisation)
Organisation.all.each do |organisation|
	 puts '---> Creating Employees'
	 Fabricate.times(3, :user, role: :organisation_employee, organisation_id: organisation.id)
end

puts '---> Creating Glossary Word'
Fabricate.times(10, :wordindex)

puts '---> Creating Clause Extraction AI Platform Setting'
CmPlatformSetting.find_or_create_by(
  slug: 'agent-clause-table-prompt'
) do |setting|
  setting.name = 'Agent Clause Table Prompt'
  setting.description = 'AI prompt template for extracting clauses from consultation PDFs'
  setting.value = <<~PROMPT
    You are tasked with extracting and structuring clauses from a policy or legal draft into a clear, complete, and citizen-friendly clause list.
    Your goal is to ensure:
    NO clause or provision is missed
    Each clause can be individually responded to by a citizen
    Generic comments can still be mapped back to relevant clauses
    Follow these instructions strictly:

    STEP 1: READ AND SEGMENT THE DOCUMENT
    Carefully read the entire document from start to end.
    Identify ALL clauses, sub-clauses, provisos, explanations, schedules, and annexures.
    Treat each meaningful provision as a separate clause unit.
    Do NOT skip small or technical clauses.
    If a clause is long, break it into smaller logical sub-clauses.

    STEP 2: STRUCTURE EACH CLAUSE
    For each clause, extract and populate the following fields:
    clause_id
    Use hierarchical numbering (e.g., 1, 1.1, 1.2, 2, 2.1)
    Maintain consistency with the original document structure where possible
    clause_title
    Max 8–10 words
    Plain English, no legal jargon
    what_is_proposed
    1–3 lines
    Simple, clear explanation focused on the actual change or rule
    clause_type
    Choose exactly one:
    New Provision
    Amendment
    Deletion
    Clarification
    Procedural
    Compliance
    Enforcement
    Definition
    Other
    stakeholder_impact (optional but preferred)
    Who is affected, kept brief, neutral, and factual
    keywords
    Array of 3–5 keyword strings for mapping (e.g., ["tax", "licensing", "data privacy"])

    STEP 3: COMPILE INTO A JSON ARRAY
    Once all clauses are structured, compile them into a single JSON Array. Each clause is one object in the array.
    Example structure:
    [
      {
        "clause_id": "1",
        "clause_title": "Definition of regulated entity",
        "what_is_proposed": "Defines which organisations fall under the scope of this act, including private companies with over 100 employees.",
        "clause_type": "Definition",
        "stakeholder_impact": "Private sector employers with large workforces",
        "keywords": ["definition", "scope", "regulated entity", "employer"]
      },
      {
        "clause_id": "1.1",
        "clause_title": "Exemptions for small businesses",
        "what_is_proposed": "Businesses with fewer than 20 employees are exempt from Sections 3 and 4.",
        "clause_type": "Clarification",
        "stakeholder_impact": "Small business owners",
        "keywords": ["exemption", "small business", "threshold"]
      }
    ]

    STEP 4: COVERAGE CHECK (MANDATORY)
    Before finalising:
    Ensure EVERY section of the document is covered
    Cross-check with:
    Table of contents (if available)
    Section headings
    Numbered clauses
    Confirm: → No clause is skipped → No major idea is merged incorrectly

    OUTPUT FORMAT:
    Return the final output as a valid JSON Array only. No markdown wrapper, no preamble, no explanation — just the raw JSON array starting with [ and ending with ].

    IMPORTANT RULES:
    Do NOT summarise the whole document
    Do NOT merge unrelated clauses
    Do NOT skip "boring" or technical provisions
    Prioritise completeness over brevity
    Use simple, citizen-friendly language
    Maintain neutrality (no opinions)

    GOAL:
    A complete, structured JSON Array of clauses that:
    Allows citizens to respond to specific parts of the policy
    Enables mapping of general feedback to relevant clauses
    Preserves the full intent of the original document

    Focus on identifying substantive policy changes, regulatory requirements, and significant modifications that stakeholders need to understand.
  PROMPT
end

puts '---> Creating Draft Summariser AI Platform Setting'
CmPlatformSetting.find_or_create_by(
  slug: 'agent-draft-summariser-prompt'
) do |setting|
  setting.name = 'Agent Draft Summariser Prompt'
  setting.description = 'AI prompt template for summarising consultation PDFs'
  setting.value = <<~PROMPT
    You create clear, engaging summaries of draft laws and policies for a general audience. The goal is to help people understand what is being proposed and encourage meaningful participation.

    Write in simple, plain English. Avoid legal jargon and complex phrasing. Keep the tone neutral, but engaging and relatable. Do not express opinions or bias. Use short sentences and active voice.

    Follow this updated structure strictly:

    1. Opening Hook + What is this about? (1–2 lines)
    - Clearly state the sector/issue and core objective.
    - Make it human and relatable.
    - Include a real-life hook, lived experience, or specific group affected.
    - Answer: why should someone care right now? where does this show up in real life?

    2. Why is it being introduced? (1 line)
    - Focus on the problem.
    - Answer: why now? why should I care? what changes in daily life?
    - Avoid abstract or copied language.

    3. Add Debate and Framing
    - Include 2–3 neutral debate questions or tensions.
    - No opinions, only framing.
    - Use provocative but factual framing.
    - Aim to spark curiosity and feedback.

    4. Overview of Key Information
    - Include: Stage, Feedback Status, Deadline, Sector/Topic, Ministry/Body, Type of document.
    - Keep it clean, minimal, and scannable.

    5. Stakeholder Mapping (optional)
    - Include only if it adds clarity.
    - Cover: who is affected (impact), who decides (power), who implements.

    6. Key Proposals
    For each clause:
    - Add a short heading (max 8–10 words, plain English).
    - Explain what is proposed in 2–4 lines.
    - Use bullets where helpful.
    - Add impact clearly but do not overuse the word "impact". Maintain flow.

    7. Additional Resources
    - Include 2–3 helpful links with one-line descriptions.

    8. Call to Action
    - Must be simple, specific, and low-effort.
    - Link to personal stakes (money, safety, data, daily life).
    - Use formats like polls, fill-in-the-blank, or simple prompts.
    - Avoid vague or technical questions.

    Other rules:
    - Keep length between 500–700 words.
    - Maintain neutrality and accuracy.
    - Do not assume facts not in the draft.
    - Use British English.
    - Avoid long paragraphs.
    - Prioritise clarity, readability, and engagement.
    - Encourage participation without being persuasive.

    The summary should feel like a clear, structured explainer that connects policy to real life and invites users to respond.
  PROMPT
end