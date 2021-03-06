import copy
import dlib
import os
import bz2
import random
from tqdm.notebook import tqdm
import shutil
import glob
import heapq
from mask2face_master.utils import image_to_array, load_image, download_data
from mask2face_master.utils.face_detection import crop_face, get_face_keypoints_detecting_function
from mask2face_master.mask_utils.mask_utils import mask_image


class DataGenerator:
    def __init__(self, configuration):
        self.configuration = configuration
        self.path_to_data = configuration.get('input_images_path')
        self.path_to_patterns = configuration.get('path_to_patterns')
        self.minimal_confidence = configuration.get('minimal_confidence')
        self.hyp_ratio = configuration.get('hyp_ratio')
        self.coordinates_range = configuration.get('coordinates_range')
        self.test_image_count = configuration.get('test_image_count')
        self.train_image_count = configuration.get('train_image_count')
        self.train_data_path = configuration.get('train_data_path')
        self.test_data_path = configuration.get('test_data_path')
        self.predictor_path = configuration.get('landmarks_predictor_path')

        self.server_media_path = configuration.get('server_media_path')

        self.check_predictor()

        self.valid_image_extensions = ('png', 'jpg', 'jpeg')
        self.face_keypoints_detecting_fun = get_face_keypoints_detecting_function(self.minimal_confidence)

    def check_predictor(self):
        """ Check if predictor exists. If not downloads it. """
        if not os.path.exists(self.predictor_path):
            print('Downloading missing predictor.')
            url = self.configuration.get('landmarks_predictor_download_url')
            download_data(url, self.predictor_path + '.bz2', 64040097)
            print(f'Decompressing downloaded file into {self.predictor_path}')
            with bz2.BZ2File(self.predictor_path + '.bz2') as fr, open(self.predictor_path, 'wb') as fw:
                shutil.copyfileobj(fr, fw)

    def get_face_landmarks(self, image):
        """Compute 68 facial landmarks"""
        landmarks = []
        image_array = image_to_array(image)
        detector = dlib.get_frontal_face_detector()
        predictor = dlib.shape_predictor(self.predictor_path)
        face_rectangles = detector(image_array)
        if len(face_rectangles) < 1:
            return None
        dlib_shape = predictor(image_array, face_rectangles[0])
        for i in range(0, dlib_shape.num_parts):
            landmarks.append([dlib_shape.part(i).x, dlib_shape.part(i).y])
        return landmarks

    def get_files_faces(self):
        """Get path of all images in dataset"""
        image_files = []
        for dirpath, dirs, files in os.walk(self.path_to_data):
            for filename in files:
                fname = os.path.join(dirpath, filename)
                if fname.endswith(self.valid_image_extensions):
                    image_files.append(fname)

        return image_files

    def generate_images(self, image_size=None, test_image_count=None, train_image_count=None):
        """Generate test and train data (images with and without the mask)"""
        if image_size is None:
            image_size = self.configuration.get('image_size')
        if test_image_count is None:
            test_image_count = self.test_image_count
        if train_image_count is None:
            train_image_count = self.train_image_count

        if not os.path.exists(self.train_data_path):
            os.mkdir(self.train_data_path)
            os.mkdir(os.path.join(self.train_data_path, 'inputs'))
            os.mkdir(os.path.join(self.train_data_path, 'outputs'))

        if not os.path.exists(self.test_data_path):
            os.mkdir(self.test_data_path)
            os.mkdir(os.path.join(self.test_data_path, 'inputs'))
            os.mkdir(os.path.join(self.test_data_path, 'outputs'))

        print('Generating testing data')
        self.generate_data(test_image_count,
                           image_size=image_size,
                           save_to=self.test_data_path)
        print('Generating training data')
        self.generate_data(train_image_count,
                           image_size=image_size,
                           save_to=self.train_data_path)

    def generate_data(self, number_of_images, image_size=None, save_to=None):
        """ Add masks on `number_of_images` images
            if save_to is valid path to folder images are saved there otherwise generated data are just returned in list
        """
        inputs = []
        outputs = []

        if image_size is None:
            image_size = self.configuration.get('image_size')

        for i, file in tqdm(enumerate(random.sample(self.get_files_faces(), number_of_images)), total=number_of_images):
            # Load images
            image = load_image(file)

            # Detect keypoints and landmarks on face
            face_landmarks = self.get_face_landmarks(image)
            if face_landmarks is None:
                continue
            keypoints = self.face_keypoints_detecting_fun(image)

            # Generate mask
            image_with_mask = mask_image(copy.deepcopy(image), face_landmarks, self.configuration)

            # Crop images
            cropped_image = crop_face(image_with_mask, keypoints)
            cropped_original = crop_face(image, keypoints)

            # Resize all images to NN input size
            res_image = cropped_image.resize(image_size)
            res_original = cropped_original.resize(image_size)

            # Save generated data to lists or to folder
            if save_to is None:
                inputs.append(res_image)
                outputs.append(res_original)
            else:
                res_image.save(os.path.join(save_to, 'inputs', f"{i:06d}.png"))
                res_original.save(os.path.join(save_to, 'outputs', f"{i:06d}.png"))

        if save_to is None:
            return inputs, outputs


    def get_dataset_path(self, userId, n=10, is_dataset_input = True, get_file_names = False):
        """
        ??? ????????? ???????????? ???????????? ????????? ???????????? ????????? ????????? ?????????
        ?????????(???????????? ?????????) ????????? ???????????? ????????? ????????? ?????? ????????????.
        """
        """
        ???????????? ??????
        userId : ????????? ID
        n = ????????? ?????????(????????????) ????????? ??????
        is_dataset_input : ??????????????? input ?????????(???????????? ?????????)??? ????????????(=True), output ?????????(????????? ?????????)??? ????????????(=False)
        """

        """
        ?????? data_path(????????? ??????)??? ????????? ???
        ????????? ??? ???????????? ?????? final_path???
        input??? ?????? output??? ?????? ??????
        """
        if is_dataset_input == True :
            final_path = '/input'
        else :
            final_path = '/output'

        """
        ????????? ?????? ??????
        ????????? media ?????? + ?????? ID + '/input/' ?????? '/output/'
        """
        data_path = self.server_media_path + userId + final_path

        """
        file_list : data_path ????????? ?????? ?????? ????????? ??? ???????????? ?????? ?????????
        latest_files : file_list??? ?????? ????????? ??? ?????? ????????? ????????? ??? n?????? ???????????? ??????
        """
        file_list = glob.glob(data_path + '/*')
        latest_files_path = heapq.nlargest(n, file_list, key = os.path.getctime)
        
        """
        final_names : latest_files_path??? ?????? ?????? ?????? ?????? ??? ????????? ????????? ????????? ???????????? ??????
        """
        file_names = [os.path.basename(i) for i in latest_files_path]

        """
        ??? ????????? ???????????? get_file_names??? ?????? ?????? ?????? ?????? ????????? ???????????? ??????????????? ?????? ??????
        """
        if get_file_names == True :
            return latest_files_path, file_names       
        else :
            return latest_files_path
        