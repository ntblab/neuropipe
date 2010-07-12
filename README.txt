== welcome to your NeuroPipe project directory

this directory was automatically created by the program *np* from the NeuroPipe
framework. it has been designed to hold a neuroscience research project that
consists of analyses of individual subjects, which are then combined into an
across-subject (group) analysis. NeuroPipe is optimized for the case that
per-subject analyses are usually identical, but occaisionally deviate because
the data collection protocol was modified to fit time constraints, a subject
fell asleep, etc...

to support these occasional deviations without overcomplicating the average case
of no deviations, NeuroPipe uses a template system. you customize the directory
*subject-template* to perform the ideal analysis for a subject. when you collect
data for a new subject, you run the command *scaffold SUBJECT_ID* which creates
a directory at *subject/SUBJECT_ID* based on the template. if there are analysis
deviations to encode for this subject, you simply change the appropriate files
in that subject's directory, and leave the template alone


== getting started

we'll start by setting you up for within-subjects analysis

first, you should open protocol.txt, and follow its directions to describe your
experimental protocol so that others can understand what your data might mean.

next, you must specify your ideal fMRI scanning protocol: what pulse sequences
you would run and in what order, if nothing went wrong. open the file
*subject-template/copy/run-order.txt*. it contains directions on how to modify
it so it fits your scanning protocol--follow them. this file will be copied into
each new subject's directory (like all other files in *subject-template/copy/*),
so you can modify it on a per-subject basis where necessary

now, collect data for a subject

next, run *./scaffold SUBJECT_ID*, with SUBJECT_ID replaced by the ID of the
subject you just collected data from. that command will set up the directory for
analyzing your new subject, and give you instructions on how to proceed. follow
them, and come back here when you've analyzed a few more subjects and are ready
to do a group analysis


== group analysis


