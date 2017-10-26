import coremltools

# Convert a caffe model to a classifier in Core ML
coreml_model = coremltools.converters.caffe.convert(('snapshot_iter_120.caffemodel',
													 'deploy.prototxt',
													 'mean.binaryproto'),
													  image_input_names = 'data',
													  class_labels = 'labels.txt',
													  is_bgr=True, image_scale=255.)

# Now save the model
coreml_model.author = "felix030"
coreml_model.save('testPerspective1.mlmodel')
