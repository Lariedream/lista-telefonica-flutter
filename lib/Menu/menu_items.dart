import 'package:flutter/material.dart';
import 'package:teste_dev/Menu/Pages/accounts.dart';
import 'package:teste_dev/Menu/menu_details.dart';
import 'Pages/deshboard.dart';




 class MenuItems{
   List<MenuDetails> items = [
     MenuDetails(title: "Inicio", icon: Icons.home, page: const Dashboard()),
     MenuDetails(title: "Contatos", icon: Icons.account_circle_rounded, page: const Accounts()),
   ];
 }