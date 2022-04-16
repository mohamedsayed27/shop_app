import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/components.dart';
import 'package:shop_app/models/categories_model.dart';
import 'package:shop_app/models/favorites_model.dart';
import 'package:shop_app/models/home_model.dart';
import 'package:shop_app/network/end_points.dart';
import 'package:shop_app/network/remote/dio_helper.dart';
import '../categories_screen.dart';
import 'package:shop_app/screens/shop_layout/cubit/shop_states.dart';
import 'package:shop_app/screens/shop_layout/favorite_screen.dart';
import 'package:shop_app/screens/shop_layout/products_screen.dart';

class ShopCubit extends Cubit<ShopStates> {
  ShopCubit() : super(ShopInitialState());

  static ShopCubit get(context) => BlocProvider.of(context);

  int currentIndex = 1;

  List<Widget> bottomNavScreens = [
    const CategoriesScreen(),
    const ProductScreen(),
    const FavoriteScreen(),
  ];

  void changeBottomNav(int index) {
    currentIndex = index;
    emit(ShopChangeBottomNavState());
  }

  HomeModel? homeModel;
  CategoriesModel? categoriesModel;
  Map<int , bool> favorites = {};

  void getHomeData() {
    emit(ShopLoadingHomeDataState());
    DioHelper.getData(url: HOME, token: token).then((value) {
      homeModel = HomeModel.fromJson(value.data);
      homeModel!.data!.products!.forEach((element) {
        favorites.addAll({element.id! : element.inFavorites!});
      });
      print(favorites);
      emit(ShopSuccessHomeDataState());
    }).catchError((error) {
      emit(ShopErrorHomeDataState(error.toString()));
    });
  }
  void getCategoriesData(){
    emit(ShopLoadingCategoriesDataState());
    DioHelper.getData(url: GET_CATEGORIES,lang: 'en').then((value) {
      categoriesModel = CategoriesModel.fromJson(value.data);
      emit(ShopSuccessCategoriesDataState());
    }).catchError((error){
      emit(ShopErrorCategoriesDataState(error));
    });
  }
  ChangeFavoritesModel? changeFavoritesModel;
  void getFavorites(int productId){
    favorites[productId] = !favorites[productId]!;
    emit(ShopFavoritesDataState());
    DioHelper.postData(
        url: FAVORITES,
        data: {'product_id' : productId} ,
        token: token
    )
        .then((value) {
          changeFavoritesModel = ChangeFavoritesModel.fromJson(value.data);
          print(changeFavoritesModel!.message);
          if(! changeFavoritesModel!.status!) {
            favorites[productId] = !favorites[productId]!;
          }
          emit(ShopSuccessFavoritesDataState(changeFavoritesModel!));
    })
        .catchError((error){
          favorites[productId] = !favorites[productId]!;
          emit(ShopErrorFavoritesDataState(error));
    });
  }
}