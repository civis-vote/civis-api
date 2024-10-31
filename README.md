# Civis API

This repository contains the codebase for the Civis API. [Civis](https://www.civis.vote/) is a bridge between citizens and Governments, to ensure that people's voice isn't just heard but acknowledged and acted upon by those in power. More information about Civis can be found [here](https://www.civis.vote/about-us).

---

**Platform Architecture**

- The platform implements a public GraphQL API.
- Authentication is managed via an access_token which is sent as an Authorization Header.
- User Interfaces consume the GraphQL API (including the primary interface i.e www.civis.vote)
- The ERD of the platform can be found [here](https://github.com/civis-vote/civis-api/blob/develop/erd.pdf).

---

**Tech Stack**

- Ruby on Rails

---

**System Requirements**

- [Ruby](https://www.ruby-lang.org/en/downloads/) version **3.0.0** or above.
- [Imagemagick](https://imagemagick.org/) for image processing

---

**Third Party Tools**

- [Postmark](https://postmarkapp.com/) for transactional emails.
- [AWS S3](https://aws.amazon.com/s3/) for Storage
- [Facebook OAuth](https://developers.facebook.com/docs/facebook-login/web/) for Login with Facebook
- [Google OAuth](https://developers.google.com/identity/protocols/OAuth2) for Login with Google
- [Scout APM](https://www.scoutapm.com/) for Application Performance Monitoring.

---

**Deployment**

- The deployment is triggered via [Cloud66](https://www.cloud66.com/) app.
- Upon building the app, a Cloud66 webhook is triggered which finally pushes the code to the server.
- Servers are hosted on AWS and managed by [Cloud66](https://www.cloud66.com/).

---

**Credentials**

- Postmark API Key
- AWS Access Key & Secret
- Airbrake Project Key
- Google Client ID and Secret
- Facebook App ID and Secret
- Scout Key

---

**Environment Variables**

- CLIENT_HOST
- HOST
- RAILS_MASTER_KEY

---

**Running locally**

- To run this project in localhost, do the following:
  - `bundle install`
  - `rails db:setup`
  - `rails s`
- To seed the database run `rails db:seed`

---

**Exploring GraphQL API**

- Use GraphQL client such as [Postman](https://www.postman.com/) testing and interacting with the GraphQL API. .
  ![Postman GraphQL](https://civis-staging-api.s3.ap-south-1.amazonaws.com/Screenshot+2024-10-31+at+6.12.25%E2%80%AFPM.png)
- GraphQL endpoint will be at `/graphql`. Examples:
  - Staging: `https://api-staging.civis.vote/graphql`
  - Production: `https://api.civis.vote/graphql`.
- To fetch GraphQL schema, use interospection query on GraphQL client.
- To use API, pass your api key, in `Authorization` headers.

---

**Notes**

- The project uses a few scripts to import data, the commands are -
  - `rails import_records_from_csv:ministry_categories`
  - `rails import_records_from_csv:ministries`
  - `rails import_records_from_csv:locations`
  - `rails import_records_from_csv:consultations`
  - `rails import_records_from_csv:point_scale`
- The API is based on GraphQL and hosted on `BASE_URL/graphql`
- If you encountered active storage attachment errors
  - `PG::UndefinedTable - ERROR: relation "active_storage_attachments" does not exist`
  - run `rails active_storage:install` and `migrate`
