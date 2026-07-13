Automated Serverless AWS Cloud Resource Monitor 

System Architecture: Engineered a 100% serverless, zero-cost cloud monitoring pipeline that tracks AWS infrastructure footprints across EC2, S3, Lambda, and IAM services.

Automated Data Pipeline: Automated infrastructure telemetry collection using a decoupled Bash + AWS CLI script running via GitHub Actions cron schedules every 15 minutes, securely authenticating via IAM access keys.

Serverless Backend Engine: Developed a high-performance Python AWS Lambda function integrated with Amazon API Gateway (HTTP API) to ingest JSON tracking payloads, manage Cross-Origin Resource Sharing (CORS), and continuously update state transitions in a single-row Amazon DynamoDB snapshot table.

Real-time Alerting: Incorporated an automated alert system utilizing Amazon SNS to track active infrastructure limits and instantly dispatch real-time email warnings if active EC2 cluster sizes breach safety thresholds.

Modern CI/CD Deployment: Isolated frontend and backend components, hosting a responsive vanilla JS control panel on Vercel with a seamless Git-driven deployment pipeline for continuous frontend synchronization.


Blueprint and setup for this project will be provided here soon!
