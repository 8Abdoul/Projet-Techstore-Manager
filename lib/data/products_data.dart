import '../models/product.dart';

const featuredProductIds = {'p1', 'p2', 'p3'};

const List<Product> demoProducts = [
  Product(
    id: 'p1',
    title: 'Casque Bluetooth',
    description: 'Casque audio sans fil avec réduction de bruit et autonomie longue durée.',
    price: 79.99,
    imageUrl: 'https://picsum.photos/seed/headset/600/400',
  ),
  Product(
    id: 'p2',
    title: 'Smartwatch',
    description: 'Montre connectée : suivi activité, notifications et capteurs santé.',
    price: 99.90,
    imageUrl: 'https://picsum.photos/seed/watch/600/400',
  ),
  Product(
    id: 'p3',
    title: 'Clavier Mécanique',
    description: 'Clavier mécanique RGB, confortable pour coder et jouer.',
    price: 59.50,
    imageUrl: 'https://picsum.photos/seed/keyboard/600/400',
  ),
  Product(
    id: 'p4',
    title: 'Souris Gaming',
    description: 'Souris précise avec DPI réglable et design ergonomique.',
    price: 24.99,
    imageUrl: 'https://picsum.photos/seed/mouse/600/400',
  ),
  Product(
    id: 'p5',
    title: 'SSD 1 To',
    description: 'SSD rapide 1 To pour booster les performances de ton PC.',
    price: 74.00,
    imageUrl: 'https://picsum.photos/seed/ssd/600/400',
  ),
  Product(
    id: 'p6',
    title: 'Enceinte Portable',
    description: 'Enceinte Bluetooth portable, son puissant, résistante.',
    price: 39.99,
    imageUrl: 'https://picsum.photos/seed/speaker/600/400',
  ),
];
