#!/bin/bash
#Author: Naz Al-Aidroos
#Edited by: Alexa Tompary

source globals.sh

#rescaffold each subject
for subj in $ALL_SUBJECTS; do
	rm -f $PROJECT_DIR/subjects/$subj/copy.sh
	bash $PROJECT_DIR/scaffold $subj
done