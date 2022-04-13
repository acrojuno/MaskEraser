from django.db import models

# Create your models here.

def input_directory_path(instance, filename):
    return f'{instance.userId}/input/{filename}'

def output_directory_path(instance, filename):
    return f'{instance.userId}/outputt/{filename}'

class Mask2faceDB(models.Model):
    userId = models.CharField(max_length=200)
    input = models.ImageField(upload_to = input_directory_path)
    output = models.ImageField(upload_to = output_directory_path, blank=True)
    quantity = models.IntegerField(null=True)