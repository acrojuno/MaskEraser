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
        본 함수는 사용자가 업로드한 이미지 파일들의 경로를 리턴해 주거나
        변환된(마스크가 지워진) 이미지 파일들의 경로를 리턴해 주는 함수이다.
        """
        """
        파라미터 설명
        userId : 유저의 ID
        n = 유저가 요청한(업로드한) 파일의 개수
        is_dataset_input : 리턴값으로 input 데이터(오리지널 이미지)를 원하는지(=True), output 데이터(변환된 이미지)를 원하는지(=False)
        """

        """
        아래 data_path(이미지 경로)를 지정할 때
        경로의 맨 마지막에 오는 final_path가
        input이 될지 output이 될지 결정
        """
        if is_dataset_input == True :
            final_path = '/input'
        else :
            final_path = '/output'

        """
        이미지 경로 지정
        본인의 media 폴더 + 유저 ID + '/input/' 또는 '/output/'
        """
        data_path = self.server_media_path + userId + final_path

        """
        file_list : data_path 경로에 있는 모든 폴더명 및 파일명을 담은 리스트
        latest_files : file_list에 있는 파일들 중 가장 최근에 업로드 된 n개의 파일들의 경로
        """
        file_list = glob.glob(data_path + '/*')
        latest_files_path = heapq.nlargest(n, file_list, key = os.path.getctime)
        
        """
        final_names : latest_files_path에 있는 전체 파일 경로 중 파일명 부분만 떼어내 리스트에 저장
        """
        file_names = [os.path.basename(i) for i in latest_files_path]

        """
        본 함수의 매개변수 get_file_names의 값에 따라 리턴 값에 파일명 리스트를 포함시킬지 말지 결정
        """
        if get_file_names == True :
            return latest_files_path, file_names       
        else :
            return latest_files_path
        