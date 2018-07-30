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

vals = {
    'deployment_network': "PAS-Deployment",
    'az1': 'az1',
    'az2': 'az2',
    'az3': 'az3',
    'service_network': 'PAS-Services', 
    'opsmgr_url': 'https://opsmgr-01.haas-147.pez.pivotal.io'
    }


#with open("template/p-healthwatch-1.yml", "r") as in_file:
#	with open("configured-template/haas147_p-healthwatch-1.0.0.yml", "w") as out_file:
#		for line in in_file:
#			out_file.write(line)


with open("template/p-healthwatch-1.yml", "r") as in_file:
	with open("configured-template/haas147_p-healthwatch-1.0.0.yml", "w") as out_file:
    		t = in_file.read()
    		rendered = jinja2.Template(t).render(vals)
    		out_file.write(rendered)



