from catchecker import create_app
import os

os.environ["SESSION_SECRET"]="MySessionSecret" 
os.environ["AZURE_CV_SUBSCRIPTION_KEY"]="YOURAZURECVKEY"
os.environ["AZURE_CV_ENDPOINT"]="your_azure_cv_endpoint"
os.environ["AWS_BUCKET_URL"]="https://my-media.s3.eu-west-3.amazonaws.com/"
os.environ["AWS_BUCKET_SQ_URL"]="https://my-mediasquared.s3.eu-west-3.amazonaws.com/"

app = create_app()
app.run()
