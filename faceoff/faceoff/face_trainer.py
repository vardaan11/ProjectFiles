#FaceOff by @darthvardaan
#Step02:Train a Computer Vision Model on the stored images.
#We do it using the OpenCV library in python.Remember that
#each face will have a different id, and it is required to
#remember which face has which id.

#import opencv-contri-python for using opencv,
#os module for interacting with the operating system,
#numpy module for highly optimised numerical operations in
#Matlab-style syntax enabling opencv arrays to be converted to
#numpy style arrays as it also helps to integrate easily with
#other libraries that use numpy like SciPy and Matplotlib,
#From the Python Imaging Library immport Image function for
#reading images.
import cv2
import os
import numpy as np
from PIL import Image
#LBPHFaceRecognizer_create() creates a model, and then we supply
#the training images to the model for facial recognition.
#LBPH stands for local binary part in histogram which is a
#algorithm that uses pixel intensities and their variations to
#map and recognize a particular face.
recognizer=cv2.face.LBPHFaceRecognizer_create()
#We supply the path where samples of all ids are stored.
path='dataset'
#We create a function that takes all images from the path and
#converts them to numpy arrays.
def getImagesWithID(path):
    #we join all the sample images' path with the directory dataset's. 
    imagePaths=[os.path.join(path,f) for f in os.listdir(path)]
    #We create 2 empty arrays to store the numpy arrays of faces and
    #their respective ids.
    faces=[]
    IDs=[]

    for imagepath in imagePaths:
        #open img and store in faceImg.
        faceImg=Image.open(imagepath).convert('L')
        #convert the face image to a numpy array.
        faceNp=np.array(faceImg,'uint8')
        print(imagepath)
        #We obtain the face ID by splitting the path.
        ID=int(os.path.split(imagepath)[-1].split(".")[1])
        #dataset/User.1.3
        #We append the faces and Ids that we get from above ops.
        faces.append(faceNp)
        IDs.append(ID)
        cv2.imshow("training",faceNp)
        cv2.waitKey(10)
        #return the numpy arrays of faces and their ids.
    return np.array(IDs),faces
#Function call for the above function, we get the faces and IDs
Ids,faces=getImagesWithID(path)
#We supply these faces and ID numpy arrays to the recognizer/training model
recognizer.train(faces,Ids)
#the trained model is thus saved in the given file
recognizer.save('trainingData.yml')
#destroy all windows
cv2.destroyAllWindows()
        

