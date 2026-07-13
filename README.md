### 📌 Project Title

**Automated Serverless AWS Infrastructure Monitor**

### 📝 Project Description

I built a completely serverless, zero-cost cloud infrastructure monitoring pipeline that tracks resource footprints across EC2, S3, Lambda, and IAM dynamically! 🚀

The project bridges automation, cloud-native engineering, and modern DevOps pipelines to solve a real-world infrastructure problem: keeping real-time tabs on active cloud footprints without accumulating premium compute costs.

#### 🔧 How It Works (Step-by-Step Architecture)

1. **Automated Collection (The Engine):** A customized Bash script integrated with the AWS CLI runs quietly in the cloud via **GitHub Actions** workflows every 15 minutes. It sweeps the AWS account to tally running microservices, storage buckets, and IAM roles.
2. **Secure Routing (The Doorway):** The system passes this dataset securely through **Amazon API Gateway** utilizing environment variable tokens rather than hardcoded credentials. It leverages optimized HTTP APIs and configured CORS layers to route cross-domain traffic.
3. **Smart Backend Processing (The Brains):** An **AWS Lambda** function compiled in Python ingests the incoming JSON strings. It overwrites a single-record 'latest' snapshot inside an **Amazon DynamoDB** table to keep data queries fast and lightweight.
4. **Instant Safeguards (The Guardrail):** The backend checks your active infrastructure sizes dynamically. If running nodes scale past safety limits, the function calls **Amazon SNS** to push a real-time email warning right into my inbox.
5. **Decoupled Frontend (The Mirror):** The frontend dashboard is hosted on **Vercel** and connects directly to the repository. The moment I update the user interface code locally and execute a `git push`, Vercel recreates the environment instantly globally. When opened, it fetches raw live metrics straight from the API.

#### 🛠️ Tech Stack Employed

* **Cloud Infrastructure:** AWS (Lambda, DynamoDB, API Gateway, SNS, IAM, CLI)
* **DevOps & CI/CD:** GitHub Actions, Linux Environment (Ubuntu), Git Version Control
* **Frontend & Hosting:** Vercel, Vanilla JavaScript, HTML5, CSS3

Full Blueprint will be provided soon!
