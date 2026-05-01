---

# 🚀 Churn Model MLOps

A compact, end-to-end example demonstrating how to apply **MLOps principles** for building and serving a customer churn prediction model.

---

## 🎯 What This Project Does

### 🏢 Business Context

Consider a telecom company with a large customer base. Some users remain loyal for years, while others stop using the service after a short time — this is known as **churn**.

This project focuses on predicting **which customers are likely to churn**, enabling proactive action.

---

### 👤 Example Customer

* **Name:** John
* **Age:** 38
* **Tenure:** 12 months
* **Monthly Charges:** $65.50
* **Total Spend:** $786
* **Support Calls:** 5

---

### 🤖 Model Output

```json
{
  "churn": 1,
  "churn_probability": 0.73
}
```

---

### 🔍 Interpretation

* `churn = 1` → Customer likely to leave
* `0.73` → 73% probability

👉 Possible reasons:

* Frequent support interactions → dissatisfaction
* Higher monthly charges → pricing concern
* Moderate tenure → not fully loyal

---

### 💡 Business Value

With these insights, organizations can:

* Provide targeted offers or discounts
* Improve customer support experience
* Engage customers before they leave

👉 The goal is to **prevent churn instead of reacting to it**

---

### 🧠 Model Behavior

The model identifies patterns such as:

* 💸 Higher billing → increased churn likelihood
* 📞 More support calls → dissatisfaction signal
* ⏳ Lower tenure → weak customer attachment

---

## 📂 Project Structure

```
churn-model/
├── generate_data.py          # Synthetic dataset creation
├── train.py                  # Model training script
├── api.py                    # FastAPI inference server
├── requirements.txt          # Dependencies
├── Dockerfile                # Container definition
├── .dvc/config               # DVC configuration
├── models/
│   └── churn_model.pkl.dvc   # Model tracked via DVC
├── k8s/
│   ├── deployment.yaml       # Kubernetes deployment
│   └── inference.yaml        # KServe inference config
├── .github/workflows/
│   └── mlops-pipeline.yaml   # CI/CD pipeline
└── argocd/
    └── application.yaml      # GitOps deployment
```

---

## 🧠 Simple Explanation (No confusion)

### 🔹 Step 1: What is `X` and `y`

```python
X = df[features]
y = df['churn']
```

* **X** → Input data (features)

  * age, tenure, charges etc.
* **y** → Output (what you want to predict)

  * churn (Yes/No)

👉 Think:

* X = Questions
* y = Answers

---

# 🔹 Step 2: Train vs Test

```python
train_test_split(X, y, test_size=0.2)
```

👉 Splits data into 2 parts:

| Type  | Purpose           |
| ----- | ----------------- |
| Train | Learn             |
| Test  | Check performance |

👉 Example:

* 80% → Train
* 20% → Test ([Real Python][1])

---

# 🔥 Final Variables (Main Part)

## 🟢 X_train

* Input data used to **train model**
* Model learns patterns from this

---

## 🟢 y_train

* Correct answers for training data
* Helps model learn what is right

👉 Together:

```text
X_train + y_train → teaching the model
```

---

## 🔵 X_test

* New unseen input data
* Model will try to predict on this

---

## 🔵 y_test

* Actual correct answers for test data
* Used to check accuracy

👉 Together:

```text
X_test + y_test → exam for model
```

---

# 🧠 Easy Analogy (Best way to remember)

| Concept | Real Life          |
| ------- | ------------------ |
| X_train | Practice questions |
| y_train | Answer sheet       |
| X_test  | Exam questions     |
| y_test  | Exam answer key    |

👉 Model:

* Learns from practice
* Tested in exam


---



## ⚙️ MLOps Pipeline

### 1️⃣ Initial Setup

```bash
uv pip install -r requirements.txt

python generate_data.py
python train.py

python api.py
# Open: http://localhost:8000/docs
```

---

### 2️⃣ DVC (Data Version Control)

```bash
dvc init

dvc remote add -d myremote s3://my-bucket/churn-model
dvc remote list

dvc add models/churn_model.pkl
dvc push

git add models/churn_model.pkl.dvc .dvc/ .gitignore
git commit -m "Track model with DVC"
```

---

### 3️⃣ Upload Model to S3

```bash
export AWS_ACCESS_KEY_ID=your-key
export AWS_SECRET_ACCESS_KEY=your-secret
export AWS_DEFAULT_REGION=us-east-1

aws s3 mb s3://my-bucket

dvc push

aws s3 ls s3://my-bucket/churn-model/models/ --recursive
```

📌 Model path:

```
s3://my-bucket/churn-model/models/churn_model.pkl
```

---

### 4️⃣ S3 Usage

S3 acts as the **remote storage backend** for DVC-managed models.

---

### 5️⃣ Kubernetes (KIND)

```bash
kind create cluster --name churn-model
```

---

### 6️⃣ KServe Deployment

```bash
kubectl apply -f https://github.com/kserve/kserve/releases/download/v0.11.0/kserve.yaml

kubectl apply -f k8s/serviceaccount.yaml
kubectl apply -f k8s/inference.yaml

kubectl get inferenceservice -n churn-model
kubectl get inferenceservice churn-predictor -n churn-model -w
```

⚠️ Ensure AWS credentials are updated in `serviceaccount.yaml`.

---

### 7️⃣ Test Inference

```bash
kubectl port-forward -n churn-model service/churn-predictor-predictor-default 8080:80
```

```bash
curl -X POST http://localhost:8080/v1/models/churn-predictor:predict \
  -H "Content-Type: application/json" \
  -d '{
    "instances": [[45, 24, 79.99, 1920.00, 3]]
  }'
```

```bash
curl -X POST http://localhost:8090/v1/models/churn-predictor:predict \
  -H "Content-Type: application/json" \
  -d '{
    "instances": [[69,64,30.142082844921653,2933.852650794406,7]]
  }'
```

---

### ✅ Expected Response

```json
{
  "predictions": [1]
}
```

---

## 🔄 CI/CD with GitHub Actions

### 🔐 Required Secrets

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`

### ⚙️ Pipeline Flow

1. Code pushed to GitHub
2. Workflow triggers:

   * Data generation
   * Model training
   * DVC push to S3
   * Docker build
   * Push to ECR
   * Update `inference.yaml`
3. Commit triggers ArgoCD

---

## 🔁 GitOps with ArgoCD

```bash
kubectl create namespace argocd

kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl apply -f argocd/application.yaml

kubectl port-forward svc/argocd-server -n argocd 8080:443

kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

---

## 🔄 End-to-End Workflow

1. Developer pushes code
2. CI pipeline runs:

   * Train model
   * Push model to S3
   * Build & push Docker image
   * Update manifests
3. ArgoCD detects changes
4. Kubernetes deployment updated
5. KServe serves latest model

---

## 🔌 API Example

```bash
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{
    "age": 45,
    "tenure_months": 24,
    "monthly_charges": 79.99,
    "total_charges": 1920.00,
    "num_support_calls": 3
  }'
```

---

### 📤 Response

```json
{
  "churn": 1,
  "churn_probability": 0.73
}
```

---

## 🧩 Core Components

* **DVC** → Versioning for data & models
* **S3** → Remote storage backend
* **KServe** → Model serving on Kubernetes
* **KIND** → Local cluster for testing
* **GitHub Actions** → CI/CD automation
* **ArgoCD** → GitOps deployment

---

## ⚠️ Notes

* Replace `your-registry` with your container registry
* Replace `your-org` with your GitHub org
* Replace `my-bucket` with your S3 bucket
* This is a **demo setup** — production requires monitoring, logging, and security enhancements

---

## 🛠 Troubleshooting

Flow reference:

```text
DVC → KServe → Kubernetes → GitHub Actions → ArgoCD
```
 
---
