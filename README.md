# โครงงาน Go Plan : Mobile Application สำหรับวางแผนการเดินทาง

ผู้จัดทำ : **B6220730 นายชวรัฐ  นาริต**  

โดยมีรายละเอียดต่างๆดังนี้
1. ไฟล์ **go_plan_v8** คือ ไฟล์ source code flutter ของโปรเจคนี้ สามารถ download ได้เลยครับ
   ในการรันสามารถรันได้โดยไปที่ main.dart แล้ว start (Fn+F5) หรือ flutter run lib/main.dart
   
* *ในการรันโปรเจคอาจต้องใช้ simulator ในการแสดงหน้าแอพ ต้องทำการติดตั้ง android studio เสียก่อน*

2. ไฟล์ **dbGoplan.json** คือ database ตัวอย่าง ที่เป็น json ของโปรเจ็คนี้
   โดยโครงสร้างการเก็บข้อมูลของผม มีดังนี้
   
     
     ![gp_pics_1](https://user-images.githubusercontent.com/71183033/201469139-21c7cad1-3d20-485b-a79a-dfe541048ce4.PNG)

      * ผมจะมี collection หลักๆ 2 ตัว คือ users ที่เก็บข้อมูล user และ trips ที่เก็บข้อมูลทริป

     # collection users
     
     ![image](https://user-images.githubusercontent.com/71183033/201469268-591bef41-e88f-4cdf-b98f-24f8036b6aa1.png)
     
      * มีโครงสร้าง คือ document ที่เก็บ id และ มี data ที่เก็บ createdAt, email, id, name, userImage
      * โดย userImage จะใช้บริการในส่วนของ firebase storage
      
      # collection trips
      
      ![image](https://user-images.githubusercontent.com/71183033/201469344-6f9f55b3-ff67-4035-8313-c253fcc71b13.png)
      
      * มีโครงสร้างคือ document ที่เก็บ id มี data ที่เก็บ createdAt, dateRange, email, endDate, isPublic, likes, name, startDate, totalCost, tripId,
        tripImage, tripTitle, uploadedBy, userImage, userLike
      * โดย tripImage และ userImage จะใช้บริการในส่วนของ firebase storage
      * นอกจากนี้ยังมีข้อมูลในส่วนของ sub collection ที่เก็บข้อมูลในแต่ละวัน เช่น จากตัวอย่างจะมี Day 1, Day 2, Day 3
     
      ![image](https://user-images.githubusercontent.com/71183033/201469464-3e991bd7-bbab-4cc3-be7b-7066c474f7d4.png)
      
      * ซึ่งใน sub collection นี้ก็จะมี document ที่เก็บ id และ มี data ที่เก็บ cost, day, detail, location, location_lat, location_lng, taskId, taskImageUrl,
        time, title, tripId,uploadedBy
      * โดย taskImageUrl จะใช้บริการในส่วนของ firebase storage
     
   
3. ไฟล์ **B6220730_ชวรัฐ  นาริต.pdf** คือ สไลด์นำเสนอของโปรเจค
