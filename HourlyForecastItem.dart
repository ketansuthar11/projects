import 'package:flutter/material.dart';

class HourlyForecastItem extends StatelessWidget {
  final String time;
  final IconData icon;
  final String tempreture;
  const HourlyForecastItem({
    super.key,required this.time,required this.icon,required this.tempreture,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(10.0),
        decoration:  BoxDecoration(
            borderRadius: BorderRadius.circular(13)
        ),
        child:  Column(
          children: [
            Text(time,style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),maxLines: 1,overflow: TextOverflow.ellipsis,),
            const SizedBox(height: 10,),
            Icon(icon, size: 32,),
            const SizedBox(height: 10,),
            Text(tempreture, style: const TextStyle(fontSize: 13, color: Colors.white54),),
          ],
        ),
      ),
    );
  }
}

