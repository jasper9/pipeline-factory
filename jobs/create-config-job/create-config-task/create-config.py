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


print("Let's get it started")
print("Deployment network is " + tile1_spec['deployment_network'])

# vals = {
#     'deployment_network': tile1_spec['deployment_network'],
#     'az1': tile1_spec['az1'],
#     'az2': tile1_spec['az2'],
#     'az3': tile1_spec['az3'],
#     'service_network': tile1_spec['service_network'], 
#     'opsmgr_url': tile1_spec['opsmgr_url']
#     }

# for key in tile1_spec:
# 	print(key + " == " + tile1_spec[key])

#with open("template/p-healthwatch-1.yml", "r") as in_file:
#	with open("configured-template/haas147_p-healthwatch-1.0.0.yml", "w") as out_file:
#		for line in in_file:
#			out_file.write(line)


with open("pipeline-factory-templates/p-healthwatch_"+tile1_spec['version']+".yml", "r") as in_file:
	with open("config/p-healthwatch.yml", "w") as out_file:
    		t = in_file.read()
    		#rendered = jinja2.Template(t).render(vals)
    		
    		#for key in tile1_spec:	
    		rendered = jinja2.Template(t).render(tile1_spec)

    		out_file.write(rendered)



