from .db import get_db
from psycopg2.extras import RealDictCursor
from datetime import datetime
from flask import g

#FROM AZURE COMPUTER VISION
from azure.cognitiveservices.vision.computervision import ComputerVisionClient
from azure.cognitiveservices.vision.computervision.models import OperationStatusCodes
from azure.cognitiveservices.vision.computervision.models import VisualFeatureTypes
from msrest.authentication import CognitiveServicesCredentials
import os
import unicodedata

def strip_accents(s):
   return ''.join(c for c in unicodedata.normalize('NFD', s)
                  if unicodedata.category(c) != 'Mn')

def tokenize(s):
    tokens = []
    finaltokens = []
    if s != None:
        if len(s)>0:
            tokens = s.split()
    
    for token in tokens:
        token = token.lower()
        token = token.replace("ß", "ss")
        token = token.replace("ø", "o")
        token = token.replace("ç", "c")
        token = strip_accents(token)

        finaltokens.append(token)

    return finaltokens

cat_words = ['cat', 'cats', 'feline', 'kitten', 'kittens','felidae']
def has_to_do_with_cats(str):
    tokens = tokenize(str)
    for t in tokens:
        if t in cat_words:
            return True
    return False

def db_image_is_cat(image, db):

    '''
    Authenticate
    Authenticates your credentials and creates a client.
    '''
    
    subscription_key = os.environ["AZURE_CV_SUBSCRIPTION_KEY"]
    endpoint = os.environ["AZURE_CV_ENDPOINT"]

    computervision_client = ComputerVisionClient(endpoint, CognitiveServicesCredentials(subscription_key))
    '''
    END - Authenticate
    '''
    
    s3url = os.environ["AWS_BUCKET_URL"]+image['img_filename']
    s3squrl = os.environ["AWS_BUCKET_SQ_URL"]+image['img_th_filename']

    
    '''
    Tag an Image - remote
    '''
    
    # Call API with remote complete image
    tags_result_full_image = computervision_client.tag_image(s3url)
    # Call API with remote thumbnail
    tags_result_thumbnail = computervision_client.tag_image(s3squrl)

    #Build log strings
    full_image_str = ''
    for tag in tags_result_full_image.tags:
        full_image_str += "{} -> {:.2f} | ".format(tag.name, tag.confidence)

    thumbnail_str = ''
    for tag in tags_result_thumbnail.tags:
        thumbnail_str += "{} -> {:.2f} | ".format(tag.name, tag.confidence)

    #LOG RESULTS
    cur = db.cursor(cursor_factory=RealDictCursor)
    cur.execute("""INSERT INTO catloader.tbl_log_ai
                    (img_id, 
                    lai_tagres_full_image, 
                    lai_tagres_thumb, 
                    aut_id)
	                VALUES (%s, %s, %s, %s)""",
                    (image['img_id'], full_image_str, thumbnail_str, image['aut_id'], ))
    db.commit()
    cur.close()


    tags_total = tags_result_full_image.tags + tags_result_thumbnail.tags
    # Analyze results with confidence score
    for tag in tags_total:
        tag_name = tag.name
        tag_confidence = tag.confidence
        if has_to_do_with_cats(tag_name) and tag_confidence >0.8:
            return True
    '''
    END - Tag an Image - remote
    '''
    return False


def db_validate_images():

    #GET ALL IMAGES TO BE VALIDATED
    db = get_db()
    cur = db.cursor(cursor_factory=RealDictCursor)

    cur.execute("""SELECT * FROM catloader.tbl_image
                    WHERE img_is_valid IS null
                    """)

    images_to_validate = cur.fetchall()
    cur.close()

    #DATA ARRAY
    image_validity = []

    for image in images_to_validate:
        #passing db for logging purposise
        if db_image_is_cat(image, db): 
            image_validity.append("("+str(image['img_id'])+", true)")
        else:
            image_validity.append("("+str(image['img_id'])+", false)")
    
    
    #SET VALIDITY OF IMAGES
    values_str = ", ".join(image_validity)

    #if there is something to update...
    if len(values_str)>0:
        #MULTI UPDATE!
        cur = db.cursor(cursor_factory=RealDictCursor)
        cur.execute("""UPDATE catloader.tbl_image as i 
                        SET img_is_valid = c.img_is_valid
                        FROM (VALUES """ + values_str + """ ) as c(img_id, img_is_valid)                    
                        WHERE c.img_id = i.img_id
                        """)
        
        db.commit()
        cur.close()

