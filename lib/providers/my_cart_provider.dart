import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mirror_me_app/models/productmain.dart';

import '../widgets/List_item_widget.dart';

class MyCartProvider extends ChangeNotifier {
  List<Productone> _productList = [];
  int totalPrice = 0;
  int amount = 0;
  List<Productone> get productList => _productList;
  int? add_item(List<Productone> productList, int? quantity) {
    int? total = 0;
    quantity == null ? quantity = 1 : quantity = quantity;
    for (var product in productList) {
      total = (total! + (product.price * quantity))!;
    }
    return total;
  }

  void fetchproduct() async {
    productList.clear();
    var userUid = FirebaseAuth.instance.currentUser?.uid;
    if (userUid != null) {
      final products = await FirebaseFirestore.instance
          .collection('cart')
          .where('userId', isEqualTo: userUid)
          .get();
      products.docs.forEach((element) {
        if (element.data().containsKey('name')) {
          productList.add(
            Productone(
              name: element.get('name'),
              price: element.get('price'),
              image: element.get('image'),
              id: element.id,
              Adress: '',
              phone: '',
              username: '',
              // amount: amount,
            ),
          );
        }
      });
      notifyListeners();
    }
  }

  bool isExist(Productone product) {
    return _productList.contains(product);
  }

  void deleteDocumentById(String id) async {
    await FirebaseFirestore.instance.collection('cart').doc(id).delete();
  }

  void removeItem(int index, final listkey) async {
    final removedItem = _productList[index];
    if (_productList.contains(removedItem)) {
      totalPrice -= removedItem.price.toInt();
      _productList.removeAt(index);
      deleteDocumentById(removedItem.id); // حذف العنصر من Firestore
      listkey.currentState!.removeItem(
        index,
        (context, animation) => ListItemWidget(
          product: removedItem,
          animation: animation,
          onclick: () {},
        ),
      );
    }

    notifyListeners();
  }
}
