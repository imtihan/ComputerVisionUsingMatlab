The exercise questions are in Lab2Exercise4Questions.
The code for Exercise 4 and the bonus exercise 5 are in the lab4.m file.
Note, the first few lines are the function calls to the function. 

ims = image_cap(100,0);     //records a sequence
videotracker(1,2,ims);      //to track from sequence
livetracker(8,2)            //to track live 
pyramidTracker(1,1)         //to track live using pyamidal tracker