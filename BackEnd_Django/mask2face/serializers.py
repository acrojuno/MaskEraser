from rest_framework import serializers
from .models import Mask2faceDB

class M2Fserializer(serializers.ModelSerializer):
    image = serializers.ImageField(use_url=True)

    class Meta:
        model = Mask2faceDB
        fields = ('userId',  'image', 'quantity')