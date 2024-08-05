#FaceOff by @darthvardaan
#Step01 : Create a database of all the images.Remember we
#use the opencv-contrib-python library as it contains all
#the main modules as well as the contributed/extra modules.

#pip install opencv-contrib-python, and not opencv-python
import cv2 
#We create a video capture object that has access to the
#webcam to click pictures.
cam = cv2.VideoCapture(0, cv2.CAP_DSHOW)
#face classifier used to detect faces in an image. We need
#to import it beforehand and make sure to put the xml file
#in the same directory where the python file is stored.
#Although haarcascades give some false-positives in face
#detection, they are still relevant due to their execution
#speed. Very useful in resource-constrained devices.
detector=cv2.CascadeClassifier('haarcascade_frontalface_default.xml')
#We store each face with a corresponding id.
Id=input('enter your id')
#each id will have multiple samples, for training the face
#recognition model. We store each sample with a distinct num.
sampleNum=0
#here we create an infinite loop, for capturing the samples
#of each id. We simply break out of this loop when we have
#collected all the samples.
while(True):
    #we try to read the image using cam.read() which returns
    #an image(img) and a boolean value(ret) that tells if the
    #operation was successful or not.
    ret, img = cam.read()
    #we convert the rgb img to grayscale img, as it is better
    #for face recognition and image processing.
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    #we call the classifier for detection and use multiScale
    #to detect faces of variable sizes in the image and create
    #recangular boxes around them and store the co-ordinates of
    #the rectangle.
    faces = detector.detectMultiScale(gray, 1.3, 5)
    #run a for-loop through the 'faces' array and plot rectangles
    #on the image with the stored variables in 'faces' array.
    for (x,y,w,h) in faces:
        #(image,co-ordinates of one corner, co-ordinates of other
        #corner, color of rectangle, thickness of lines)
        cv2.rectangle(img,(x,y),(x+w,y+h),(255,0,0),2)
        #saving the captured face in the dataset folder after cropping
        cv2.imwrite("dataSet/User."+Id +'.'+ str(sampleNum) + ".jpg", gray[y:y+h,x:x+w])
        #increment the sample number 
        sampleNum=sampleNum+1
        #display the image
        cv2.imshow('frame',img)
    #break if the sample number is more than 20
    if sampleNum>20:
        break
#release the cam object
cam.release()
#destroy all windows
cv2.destroyAllWindows()
