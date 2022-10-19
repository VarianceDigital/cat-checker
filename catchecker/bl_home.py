import time
from flask import (
    Blueprint, render_template, request, send_from_directory
)
from .layoutUtils import *
from .auth import *
from .db_catchecker import db_validate_images
bp = Blueprint('bl_home', __name__)

@bp.route('/')
def index():
    
    mc = set_menu("home") #to highlight menu option
    return render_template('home/index.html', mc=mc)


@bp.route('/about')
def about():

    mc = set_menu("about")
    return render_template('home/about.html', mc=mc)

@bp.route('/checkcatimages')
def checkcatimages():

    mc = set_menu("checkcatimages")

    db_validate_images()

    return render_template('home/checkcatimages.html', mc=mc)


@bp.route('/checkcatimages-api')
def checkcatimagesapi():
    
    db_validate_images()
    
    return {'data':'OK', 'error':0}


#MANAGE sitemap and robots calls 
#These files are usually in root, but for Flask projects must
#be in the static folder
@bp.route('/robots.txt')
@bp.route('/sitemap.xml')
def static_from_root():
    return send_from_directory(current_app.static_folder, request.path[1:])

