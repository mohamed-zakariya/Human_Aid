import 'dart:ui';

import 'package:flutter/material.dart';

final Map<String, Map<String, List<Map<String, String>>>> letterForms = {
  'ا': {
    'منفصل': [{'form': 'ا', 'example': 'أسد'}],
    'متصل': [{'form': 'ـا', 'example': 'سماء'}],
    'نهائي': [{'form': 'ـا', 'example': 'رضا'}],
  },
  'ب': {
    'منفصل': [{'form': 'ب', 'example': 'رحاب'}],
    'متصل': [
      {'form': 'بـ', 'example': 'بحر'},
      {'form': 'ـبـ', 'example': 'تبوك'},
    ],
    'نهائي': [{'form': 'ـب', 'example': 'حب'}],
  },
  'ت': {
    'منفصل': [{'form': 'ت', 'example': 'توت'}],
    'متصل': [
      {'form': 'تـ', 'example': 'تفكير'},
      {'form': 'ـتـ', 'example': 'مكتبة'},
    ],
    'نهائي': [{'form': 'ـت', 'example': 'بيت'}],
  },
  'ث': {
    'منفصل': [{'form': 'ث', 'example': 'ورث'}],
    'متصل': [
      {'form': 'ثـ', 'example': 'ثوب'},
      {'form': 'ـثـ', 'example': 'مثال'},
    ],
    'نهائي': [{'form': 'ـث', 'example': 'بحث'}],
  },
  'ج': {
    'منفصل': [{'form': 'ج', 'example': 'دجاج'}],
    'متصل': [
      {'form': 'جـ', 'example': 'جبل'},
      {'form': 'ـجـ', 'example': 'مجد'},
    ],
    'نهائي': [{'form': 'ـج', 'example': 'حج'}],
  },
  'ح': {
    'منفصل': [{'form': 'ح', 'example': 'روح'}],
    'متصل': [
      {'form': 'حـ', 'example': 'حب'},
      {'form': 'ـحـ', 'example': 'محراب'},
    ],
    'نهائي': [{'form': 'ـح', 'example': 'وَضِح'}],
  },
  'خ': {
    'منفصل': [{'form': 'خ', 'example': 'خروف'}],
    'متصل': [
      {'form': 'خـ', 'example': 'خالد'},
      {'form': 'ـخـ', 'example': 'مخرج'},
    ],
    'نهائي': [{'form': 'ـخ', 'example': 'فخ'}],
  },
  'د': {
    'منفصل': [{'form': 'د', 'example': 'دلو'}],
    'متصل': [{'form': 'ـد', 'example': 'ورد'}],
    'نهائي': [{'form': 'ـد', 'example': 'عبد'}],
  },
  'ذ': {
    'منفصل': [{'form': 'ذ', 'example': 'ذئب'}],
    'متصل': [{'form': 'ـذ', 'example': 'عرض'}],
    'نهائي': [{'form': 'ـذ', 'example': 'حذ'}],
  },
  'ر': {
    'منفصل': [{'form': 'ر', 'example': 'رجل'}],
    'متصل': [{'form': 'ـر', 'example': 'جسر'}],
    'نهائي': [{'form': 'ـر', 'example': 'أثر'}],
  },
  'ز': {
    'منفصل': [{'form': 'ز', 'example': 'زرافة'}],
    'متصل': [{'form': 'ـز', 'example': 'أرز'}],
    'نهائي': [{'form': 'ـز', 'example': 'عزيز'}],
  },
  'س': {
    'منفصل': [{'form': 'س', 'example': 'سمك'}],
    'متصل': [
      {'form': 'سـ', 'example': 'سفينة'},
      {'form': 'ـسـ', 'example': 'مسرح'},
    ],
    'نهائي': [{'form': 'ـس', 'example': 'درس'}],
  },
  'ش': {
    'منفصل': [{'form': 'ش', 'example': 'شمس'}],
    'متصل': [
      {'form': 'شـ', 'example': 'شجرة'},
      {'form': 'ـشـ', 'example': 'مشرق'},
    ],
    'نهائي': [{'form': 'ـش', 'example': 'فرش'}],
  },
  'ص': {
    'منفصل': [{'form': 'ص', 'example': 'صقر'}],
    'متصل': [
      {'form': 'صـ', 'example': 'صحيفة'},
      {'form': 'ـصـ', 'example': 'مصر'},
    ],
    'نهائي': [{'form': 'ـص', 'example': 'نقص'}],
  },
  'ض': {
    'منفصل': [{'form': 'ض', 'example': 'ضوء'}],
    'متصل': [
      {'form': 'ضـ', 'example': 'ضرب'},
      {'form': 'ـضـ', 'example': 'مضرب'},
    ],
    'نهائي': [{'form': 'ـض', 'example': 'عرض'}],
  },
  'ط': {
    'منفصل': [{'form': 'ط', 'example': 'طير'}],
    'متصل': [
      {'form': 'طـ', 'example': 'طريق'},
      {'form': 'ـطـ', 'example': 'محطة'},
    ],
    'نهائي': [{'form': 'ـط', 'example': 'ربط'}],
  },
  'ظ': {
    'منفصل': [{'form': 'ظ', 'example': 'ظبي'}],
    'متصل': [
      {'form': 'ظـ', 'example': 'ظهر'},
      {'form': 'ـظـ', 'example': 'مظلة'},
    ],
    'نهائي': [{'form': 'ـظ', 'example': 'لفظ'}],
  },
  'ع': {
    'منفصل': [{'form': 'ع', 'example': 'عين'}],
    'متصل': [
      {'form': 'عـ', 'example': 'عمل'},
      {'form': 'ـعـ', 'example': 'معلم'},
    ],
    'نهائي': [{'form': 'ـع', 'example': 'قطع'}],
  },
  'غ': {
    'منفصل': [{'form': 'غ', 'example': 'غزال'}],
    'متصل': [
      {'form': 'غـ', 'example': 'غرفة'},
      {'form': 'ـغـ', 'example': 'مغرب'},
    ],
    'نهائي': [{'form': 'ـغ', 'example': 'فرغ'}],
  },
  'ف': {
    'منفصل': [{'form': 'ف', 'example': 'فيل'}],
    'متصل': [
      {'form': 'فـ', 'example': 'فجر'},
      {'form': 'ـفـ', 'example': 'مفتاح'},
    ],
    'نهائي': [{'form': 'ـف', 'example': 'خوف'}],
  },
  'ق': {
    'منفصل': [{'form': 'ق', 'example': 'قمر'}],
    'متصل': [
      {'form': 'قـ', 'example': 'قلب'},
      {'form': 'ـقـ', 'example': 'مقعد'},
    ],
    'نهائي': [{'form': 'ـق', 'example': 'صدق'}],
  },
  'ك': {
    'منفصل': [{'form': 'ك', 'example': 'كتاب'}],
    'متصل': [
      {'form': 'كـ', 'example': 'كرة'},
      {'form': 'ـكـ', 'example': 'مكتب'},
    ],
    'نهائي': [{'form': 'ـك', 'example': 'ملك'}],
  },
  'ل': {
    'منفصل': [{'form': 'ل', 'example': 'لبن'}],
    'متصل': [
      {'form': 'لـ', 'example': 'لسان'},
      {'form': 'ـلـ', 'example': 'ملاك'},
    ],
    'نهائي': [{'form': 'ـل', 'example': 'جمل'}],
  },
  'م': {
    'منفصل': [{'form': 'م', 'example': 'موز'}],
    'متصل': [
      {'form': 'مـ', 'example': 'مكتب'},
      {'form': 'ـمـ', 'example': 'أملاك'},
    ],
    'نهائي': [{'form': 'ـم', 'example': 'علم'}],
  },
  'ن': {
    'منفصل': [{'form': 'ن', 'example': 'نمر'}],
    'متصل': [
      {'form': 'نـ', 'example': 'نهر'},
      {'form': 'ـنـ', 'example': 'منبر'},
    ],
    'نهائي': [{'form': 'ـن', 'example': 'فان'}],
  },
  'ه': {
    'منفصل': [{'form': 'ه', 'example': 'هدهد'}],
    'متصل': [
      {'form': 'هـ', 'example': 'هواء'},
      {'form': 'ـهـ', 'example': 'ذهب'},
    ],
    'نهائي': [{'form': 'ـه', 'example': 'وجه'}],
  },
  'و': {
    'منفصل': [{'form': 'و', 'example': 'وردة'}],
    'متصل': [{'form': 'ـو', 'example': 'ضوء'}],
    'نهائي': [{'form': 'ـو', 'example': 'نمو'}],
  },
  'ي': {
    'منفصل': [{'form': 'ي', 'example': 'يد'}],
    'متصل': [
      {'form': 'يـ', 'example': 'يوم'},
      {'form': 'ـيـ', 'example': 'بيان'},
    ],
    'نهائي': [{'form': 'ـي', 'example': 'كمي'}],
  },
};


final List<Color> colors = [
  Colors.red, Colors.blue, Colors.green, Colors.orange,
  Colors.purple, Colors.teal, Colors.brown, Colors.pink,
  Colors.indigo, Colors.amber, Colors.deepOrange, Colors.cyan,
  Colors.deepPurple, Colors.lime, Colors.lightBlue, Colors.lightGreen,
  Colors.yellow, Colors.blueGrey, Colors.redAccent, Colors.greenAccent,
  Colors.orangeAccent, Colors.purpleAccent, Colors.tealAccent, Colors.brown,
  Colors.pinkAccent, Colors.indigoAccent, Colors.amberAccent, Colors.cyanAccent,
];


// letter_forms.dart

final Map<String, List<Map<String, dynamic>>>  letterForms2 = {
  // 'أ': {
  //   'منفصل': [
  //     {
  //       'form': 'منفصل',
  //       'example': 'أب',
  //       'image': 'assets/images/أ_منفصل.png',
  //     },
  //   ],
  //   'متصل': [
  //     {
  //       'form': 'متصل',
  //       'example': 'أبناء',
  //       'image': 'assets/images/أ_متصل.png',
  //     },
  //   ],
  //   'نهائي': [
  //     {
  //       'form': 'نهائي',
  //       'example': 'كتاب',
  //       'image': 'assets/images/أ_نهائي.png',
  //     },
  //   ],
  // },
  // 'ب': {
  //   'منفصل': [
  //     {
  //       'form': 'منفصل',
  //       'example': 'باب',
  //       'image': 'assets/images/ب_منفصل.png',
  //     },
  //   ],
  //   'متصل': [
  //     {
  //       'form': 'متصل',
  //       'example': 'بناء',
  //       'image': 'assets/images/ب_متصل.png',
  //     },
  //   ],
  //   'نهائي': [
  //     {
  //       'form': 'نهائي',
  //       'example': 'كتاب',
  //       'image': 'assets/images/ب_نهائي.png',
  //     },
  //   ],
  // },
  // 'ت': {
  //   'منفصل': [
  //     {
  //       'form': 'منفصل',
  //       'example': 'تاج',
  //       'image': 'assets/images/ت_منفصل.png',
  //     },
  //   ],
  //   'متصل': [
  //     {
  //       'form': 'متصل',
  //       'example': 'تنمية',
  //       'image': 'assets/images/ت_متصل.png',
  //     },
  //   ],
  //   'نهائي': [
  //     {
  //       'form': 'نهائي',
  //       'example': 'كتابة',
  //       'image': 'assets/images/ت_نهائي.png',
  //     },
  //   ],
  // },
  // 'ث': {
  //   'منفصل': [
  //     {
  //       'form': 'منفصل',
  //       'example': 'ثلاثة',
  //       'image': 'assets/images/ث_منفصل.png',
  //     },
  //   ],
  //   'متصل': [
  //     {
  //       'form': 'متصل',
  //       'example': 'ثقة',
  //       'image': 'assets/images/ث_متصل.png',
  //     },
  //   ],
  //   'نهائي': [
  //     {
  //       'form': 'نهائي',
  //       'example': 'ثمين',
  //       'image': 'assets/images/ث_نهائي.png',
  //     },
  //   ],
  // },
  // // Add other letters similarly...
  // 'ج': {
  //   'منفصل': [
  //     {
  //       'form': 'منفصل',
  //       'example': 'جمل',
  //       'image': 'assets/images/ج_منفصل.png',
  //     },
  //   ],
  //   'متصل': [
  //     {
  //       'form': 'متصل',
  //       'example': 'جدير',
  //       'image': 'assets/images/ج_متصل.png',
  //     },
  //   ],
  //   'نهائي': [
  //     {
  //       'form': 'نهائي',
  //       'example': 'جار',
  //       'image': 'assets/images/ج_نهائي.png',
  //     },
  //   ],
  // },
  // 'ح': {
  //   'منفصل': [
  //     {
  //       'form': 'منفصل',
  //       'example': 'حجم',
  //       'image': 'assets/images/ح_منفصل.png',
  //     },
  //   ],
  //   'متصل': [
  //     {
  //       'form': 'متصل',
  //       'example': 'حقيقة',
  //       'image': 'assets/images/ح_متصل.png',
  //     },
  //   ],
  //   'نهائي': [
  //     {
  //       'form': 'نهائي',
  //       'example': 'حرف',
  //       'image': 'assets/images/ح_نهائي.png',
  //     },
  //   ],
  // },
  // // Continue for the rest of the Arabic alphabet...
  // 'خ': {
  //   'منفصل': [
  //     {
  //       'form': 'منفصل',
  //       'example': 'خروف',
  //       'image': 'assets/images/خ_منفصل.png',
  //     },
  //   ],
  //   'متصل': [
  //     {
  //       'form': 'متصل',
  //       'example': 'خطأ',
  //       'image': 'assets/images/خ_متصل.png',
  //     },
  //   ],
  //   'نهائي': [
  //     {
  //       'form': 'نهائي',
  //       'example': 'خارج',
  //       'image': 'assets/images/خ_نهائي.png',
  //     },
  //   ],
  // },
  // 'د': {
  //   'منفصل': [
  //     {
  //       'form': 'منفصل',
  //       'example': 'دنيا',
  //       'image': 'assets/images/د_منفصل.png',
  //     },
  //   ],
  //   'متصل': [
  //     {
  //       'form': 'متصل',
  //       'example': 'دليل',
  //       'image': 'assets/images/د_متصل.png',
  //     },
  //   ],
  //   'نهائي': [
  //     {
  //       'form': 'نهائي',
  //       'example': 'دخول',
  //       'image': 'assets/images/د_نهائي.png',
  //     },
  //   ],
  // },
  // Continue for the rest of the Arabic letters...
  'ه': [
    {
      'label': 'بداية',
      'form': 'هـ',
      'example': 'هامستر',
      'image': 'assets/images/letters/ه_منفصل.png',
    },
    {
      'label': 'وسط',
      'form': 'ـهـ',
      'example': 'فهد',
      'image': 'assets/images/letters/ه_متصل.png',
    },
    {
      'label': 'نهاية',
      'form': 'ـه',
      'example': 'منبه',
      'image': 'assets/images/letters/ه_نهائي.png',
    },
  ],
};


