#FaceOff by @darthvardaan
#Step03:We create a webpage using Streamlit. The webpage
#will take an image as input from the user and ask the
#trained model to make a classification and then return
#the output image onto the webpage.

#Streamlit is a framework for building webapps from python scripts.
import streamlit as st
import cv2
from PIL import Image
import numpy as np

#We use the face classifier to detect a face in any given image.
face_cascade = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')
#We create object for face recognizer.
rec=cv2.face.LBPHFaceRecognizer_create()
rec.read("trainingData.yml")

def detect_faces(our_image):
    #convert to RGB and then to numpy array 
    img = np.array(our_image.convert('RGB'))
    #convert to grayscale
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    # Detect faces
    faces = face_cascade.detectMultiScale(gray, 1.1, 4)
    # Draw rectangle around the faces
    for (x, y, w, h) in faces:
        # To draw a rectangle in a face
        cv2.rectangle(img, (x, y), (x + w, y + h), (255, 255, 0), 2)
        #We use rec.predict to recognize the image and return uncertainity level
        id, uncertainty = rec.predict(gray[y:y + h, x:x + w])
        print(id, uncertainty)

        #parameter for classification is the uncertainity
        if (uncertainty< 55):
            #here we classify the person depending on the uncertainity and id
            if (id == 0 or id == 1 or id == 2 ):
                cv2.putText(img, 'Vardaan', (x, y + h), cv2.FONT_HERSHEY_COMPLEX_SMALL, 2.0, (255, 255, 0),2)
            else:
                cv2.putText(img, 'Maybe Vardaan', (x, y + h), cv2.FONT_HERSHEY_COMPLEX_SMALL, 2.0, (255, 255, 0),2)
        else:
            cv2.putText(img, 'Unknown', (x, y + h), cv2.FONT_HERSHEY_COMPLEX_SMALL, 2.0, (255, 255, 0),2)
    #return the result img
    return img

def main():
    """FaceOff"""

    st.title("OpenCV Project")

    html_temp = """
    <body style="background-color:red;">
    <div style="background-color:teal ;padding:10px">
    <h2 style="color:white;text-align:center;">FaceOff - Face Recognition WebApp</h2>
    </div>
    </body>
    """
    st.markdown(html_temp, unsafe_allow_html=True)

    image_file = st.file_uploader("Upload Image", type=['jpg', 'png', 'jpeg'])
    if image_file is not None:
        our_image = Image.open(image_file)
        st.text("Original Image")
        st.image(our_image)

    if st.button("Recognise"):
        result_img= detect_faces(our_image)
        st.image(result_img)


if __name__ == '__main__':
    main()
