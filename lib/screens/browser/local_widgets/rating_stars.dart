import 'package:flutter/material.dart';

class RatingStars extends StatefulWidget {
  @override
  _RatingStarsState createState() => _RatingStarsState();
}

class _RatingStarsState extends State<RatingStars> {
  List<MaterialColor> ratingStarColors = [];

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 5; i++) {
      ratingStarColors.add(Colors.grey);
    }
  }

  void _onRatingSelected(int ratingValue) {
    print(ratingValue);
    setState(() {
      for (int i = 0; i < ratingStarColors.length; i++) {
        ratingStarColors[i] = i <= ratingValue ? Colors.amber : Colors.grey;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> ratingStars = [];

    for (int i = 0; i < 5; i++) {
      ratingStars.add(
        GestureDetector(
          onTap: () => _onRatingSelected(i),
          child: Container(
            margin: const EdgeInsets.only(top: 20, left: 5, right: 5),
            child: Icon(
              Icons.star,
              size: 40,
              color: ratingStarColors[i],
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ratingStars,
    );
  }
}
