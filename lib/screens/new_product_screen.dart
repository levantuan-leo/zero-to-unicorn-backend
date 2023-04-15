import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_backend/models/product_model.dart';
import 'package:flutter_ecommerce_backend/services/database_service.dart';
import 'package:flutter_ecommerce_backend/services/storage_service.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '/controllers/controllers.dart';

//ignore: must_be_immutable
class NewProductScreen extends StatelessWidget {
  NewProductScreen({Key? key}) : super(key: key);

  final ProductController productController = Get.find();

  StorageService storage = StorageService();
  DatabaseService database = DatabaseService();

  @override
  Widget build(BuildContext context) {
    List<String> categories = [
      'Smoothies',
      'Soft Drinks',
      'Water',
    ];
    print(productController.newProduct['imageUrl']);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a Product'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 100,
                child: Card(
                  margin: EdgeInsets.zero,
                  color: Colors.black,
                  child: Stack(alignment: Alignment.center, children: [
                    productController.newProduct['imageUrl'] != null
                        ? Positioned.fill(
                            top: 0,
                            left: 0,
                            child: Image.file(
                              File(productController.newProduct['imageUrl']),
                              fit: BoxFit.cover,
                            ))
                        : const SizedBox(),
                    Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                  source: ImageSource.gallery);

                              if (image == null) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('No image was selected.'),
                                    ),
                                  );
                                }
                              }

                              if (image != null) {
                                productController.newProduct.update(
                                    'imageUrl', (_) => image.path,
                                    ifAbsent: () => image.path);
                              }
                            },
                            icon: const Icon(
                              Icons.add_circle,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Add an Image',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Product Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildTextFormField(
                'Product Name',
                'name',
                productController,
              ),
              _buildTextFormField(
                'Product Description',
                'description',
                productController,
              ),
              DropdownButtonFormField(
                iconSize: 20,
                decoration: const InputDecoration(hintText: 'Product Category'),
                items: categories.map(
                  (value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  productController.newProduct.update(
                    'category',
                    (_) => value,
                    ifAbsent: () => value,
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildSlider(
                'Price',
                'price',
                productController,
                productController.price,
              ),
              _buildSlider(
                'Quantity',
                'quantity',
                productController,
                productController.quantity,
              ),
              const SizedBox(height: 10),
              _buildCheckbox(
                'Recommended',
                'isRecommended',
                productController,
                productController.isRecommended,
              ),
              _buildCheckbox(
                'Popular',
                'isPopular',
                productController,
                productController.isPopular,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (productController.newProduct['imageUrl'] != null) {
                      XFile image =
                          XFile(productController.newProduct['imageUrl']);
                      // Save image to cloud firestore
                      await storage.uploadImage(image);
                      var imageUrl = await storage.getDownloadURL(image.name);

                      productController.newProduct.update(
                          'imageUrl', (_) => imageUrl,
                          ifAbsent: () => imageUrl);
                    }

                    database.addProduct(
                      Product(
                        name: productController.newProduct['name'],
                        category: productController.newProduct['category'],
                        description:
                            productController.newProduct['description'],
                        imageUrl: productController.newProduct['imageUrl'],
                        isRecommended:
                            productController.newProduct['isRecommended'] ??
                                false,
                        isPopular:
                            productController.newProduct['isPopular'] ?? false,
                        price: productController.newProduct['price'],
                        quantity:
                            productController.newProduct['quantity'].toInt(),
                      ),
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row _buildCheckbox(
    String title,
    String name,
    ProductController productController,
    bool? controllerValue,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 125,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Checkbox(
          value: (controllerValue == null) ? false : controllerValue,
          checkColor: Colors.black,
          activeColor: Colors.black12,
          onChanged: (value) {
            productController.newProduct.update(
              name,
              (_) => value,
              ifAbsent: () => value,
            );
          },
        ),
      ],
    );
  }

  Row _buildSlider(
    String title,
    String name,
    ProductController productController,
    double? controllerValue,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 75,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Slider(
            value: (controllerValue == null) ? 0 : controllerValue,
            min: 0,
            max: 25,
            divisions: 10,
            activeColor: Colors.black,
            inactiveColor: Colors.black12,
            onChanged: (value) {
              productController.newProduct.update(
                name,
                (_) => value,
                ifAbsent: () => value,
              );
            },
          ),
        ),
      ],
    );
  }

  TextFormField _buildTextFormField(
    String hintText,
    String name,
    ProductController productController,
  ) {
    return TextFormField(
      decoration: InputDecoration(hintText: hintText),
      onChanged: (value) {
        productController.newProduct.update(
          name,
          (_) => value,
          ifAbsent: () => value,
        );
      },
    );
  }
}
