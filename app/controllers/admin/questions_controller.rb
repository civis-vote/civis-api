class Admin::QuestionsController < ApplicationController

    def destroy
        @question = Question.find(params[:id])
		@question.destroy
		redirect_to admin_consultation_path(params[:consultation_id]), flash_success_info: "Question was successfully deleted."
    end

    def create
		@question = Question.new(question_params)
		if @question.save
            redirect_back fallback_location: root_path, flash_success_info: "Question added"
        end
		
	end
    
    def edit
        @question = Question.find(params[:id])
    end

    def update
        @question = Question.find(params[:id])
        if @question.update(question_params)
            redirect_back fallback_location: root_path, flash_success_info: "Question was successfully updated."
        end
        
    end

    private

    def question_params
		  params.require(:question).permit(:question_text, :question_text_hindi, :question_text_odia, :response_round_id, :question_type, :is_optional, :supports_other, sub_questions_attributes: %i[id _destroy question_text question_text_hindi question_text_odia parent_id])
	end

end