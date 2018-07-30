import os,sys
import yaml
from pprint import pprint
import urllib3
from time import sleep
import json as json1
import subprocess

from collections import OrderedDict
from operator import itemgetter  

tile1_spec            = os.getenv('TILE1_SPEC', '').strip()

if tile1_spec =='':
    print('No yaml payload set for TILE1_SPEC')

tile1_spec = yaml.load(tile1_spec)


print("Let's get it started")
print("Deployment network is " + tile1_spec['deployment_network'])


with open("template.yml", "r") as in_file:
	with open("generated-config/config.yml", "w") as out_file:
		for line in in_file:
			out_file.write(line)
