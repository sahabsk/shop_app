import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import '../providers/product.dart';
import '../providers/products.dart';
import '../widgets/products_grid.dart';
import 'package:badges/badges.dart';
import '../providers/cart.dart';
import 'cart_screen.dart';
import '../widgets/app_drawer.dart';

enum FilterOptions {
  Favorite,
  All,
}

class ProductOverviewScreen extends StatefulWidget {
  // final List<Product> loadedProduct = [
  //   Product(
  //     id: 'p1',
  //     title: 'Black T-Shirt',
  //     description: 'Slim fit cotton round neck T-Shirt',
  //     price: 20.00,
  //     imageUrl:
  //         'https://static.cilory.com/365079-thickbox_default/levis-black-full-sleeves-pre-winter-t-shirt.jpg',
  //   ),
  //   Product(
  //       id: 'p2',
  //       title: 'Jacket',
  //       description: 'Real Brown Leather jacket',
  //       price: 60.00,
  //       imageUrl:
  //           'https://media.istockphoto.com/photos/mans-blank-black-leather-jacket-backisolated-on-white-wclipping-path-picture-id157440390?k=6&m=157440390&s=612x612&w=0&h=T6FPlhLStJYe9ECm05qNOBowm7uQrQgcEmEhz2IYVsA='),
  //   Product(
  //     id: 'p3',
  //     title: 'Trouser',
  //     description: 'Mens Sports Trouser',
  //     price: 25.00,
  //     imageUrl:
  //         'https://5.imimg.com/data5/SELLER/Default/2020/12/FU/FE/AE/66384849/new-product-500x500.jpeg',
  //   ),
  //   Product(
  //       id: 'p4',
  //       title: 'Shirts',
  //       description: 'Formal Mens Shirts',
  //       price: 30.00,
  //       imageUrl:
  //           'https://lh3.googleusercontent.com/proxy/T3z4fRk8kaw9XdkCGr-1yDJmk3psH5_xWVFTarvc8Yh5qh2xH06m6TuCMvX-WRVS7Sln7YpfGwazCqDLz15uZSNGKrszEw2U0dQ'),
  // ];

  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    // Provider.of<Products>(context).fetchAndSetProducts();  // Won't work
    // Future.delayed(Duration.zero).then((_) {
    //   Provider.of<Products>(context).fetchAndSetProducts();
    // });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final productsContainer = Provider.of<Products>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("MyShop"),
        actions: <Widget>[
          PopupMenuButton(
              onSelected: (FilterOptions selectedValue) {
                // print(selectedValue);
                setState(() {
                  if (selectedValue == FilterOptions.Favorite) {
                    _showOnlyFavorites = true;
                  } else {
                    _showOnlyFavorites = false;
                  }
                });
              },
              icon: Icon(Icons.more_vert),
              itemBuilder: (_) => [
                    PopupMenuItem(
                      child: Text('Only Favorite'),
                      value: FilterOptions.Favorite,
                    ),
                    PopupMenuItem(
                      child: Text('Show All'),
                      value: FilterOptions.All,
                    ),
                  ]),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch,
              // value:cart.itemCount.toString()
            ),
            child: IconButton(
              icon: Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFavorites),
    );
  }
}
