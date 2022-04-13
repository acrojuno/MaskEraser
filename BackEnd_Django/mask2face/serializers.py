from rest_framework import serializers
from .models import Mask2faceDB

class M2Fserializer(serializers.ModelSerializer):

    class Meta:
        model = Mask2faceDB
        fields = ('userId',  'input', 'output', 'quantity')
        
    