import os,sys
import yaml
from pprint import pprint
import urllib3
from time import sleep
import json as json1
import subprocess

from collections import OrderedDict
from operator import itemgetter  

import jinja2

tile1_spec            = os.getenv('TILE1_SPEC', '').strip()

if tile1_spec =='':
    print('No yaml payload set for TILE1_SPEC')

tile1_spec = yaml.load(tile1_spec)

template = tile1_spec['slug'] + "_"+tile1_spec['version']+".yml"
config_out = tile1_spec['slug'] + ".yml"

#print("Let's get it started")
#print("Deployment network is " + tile1_spec['deployment_network'])

print("Slug: " + tile1_spec['slug'])
print("Version: " + tile1_spec['version'])
print("Input Template: " + template)
print("Output Config: " + config_out)

with open("pipeline-factory-templates/" + template, "r") as in_file:
	with open("config/" + config_out, "w") as out_file:
    		t = in_file.read()
    		#rendered = jinja2.Template(t).render(vals)
    		
    		#for key in tile1_spec:	
    		rendered = jinja2.Template(t).render(tile1_spec)

    		out_file.write(rendered)



