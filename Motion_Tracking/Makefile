########################################################################
#
#  DESCRIPTION  : Makefile for Motion Tracking
# 
#  PLATFORM		: Linux
#
#Reference: Ioannis Karamouzas (ioannis@clemson.edu)
########################################################################

#compiler
CC = gcc

#auxiliary flags
CFLAGS	= -g


#executable name
PROJECT = motion_tracking

#list of all .o file for each .cpp file
OBJECTS := motion_tracking.o
OBJECTS += functions.o		

#this does the linking step  
all: ${PROJECT}
${PROJECT} : ${OBJECTS} 
	${CC} ${CFLAGS} -o ${PROJECT} ${OBJECTS} ${LDFLAGS} 

#compile the code 
%.o: %.cpp
	${CC} -c ${CFLAGS} $<
	
#this will clean up all temporary files created by make all
clean:
	rm -f core.* *.o *~ ${PROJECT}
