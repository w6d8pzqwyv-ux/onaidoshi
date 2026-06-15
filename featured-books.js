// featured-books.js — 「買える本（新刊が流通する現代の人気小説）」優先表示リスト
// 目的: 古典は無料代替があり買われにくい。現代の人気作を結果上位に寄せて購入確率を上げる。
// 仕様: 各言語、"タイトル|著者" の完全一致で判定。該当本がその年齢にあれば結果の上位に寄せる。
// 注意: 文字列は books-data-XX.js の実データと完全一致させること（再生成で表記が変わったら要更新）。
// 編集: 載せたい本を追記/削除するだけ。年齢が分散するほど多くの訪問者に効く。
window.FEATURED = {
  en: [
    "Divergent|Veronica Roth",
    "The Book Thief|Markus Zusak",
    "The Fault in Our Stars|John Green",
    "The Help|Kathryn Stockett",
    "A Thousand Splendid Suns|Khaled Hosseini",
    "The Three-Body Problem|Liu Cixin",
    "The Hunger Games|Suzanne Collins",
    "Project Hail Mary|Andy Weir",
    "The Museum of Innocence|Orhan Pamuk",
    "1Q84|Haruki Murakami",
    "A Dance with Dragons|George R. R. Martin"
  ],
  es: [
    "Insurgente|Veronica Roth",
    "Un hombre llamado Ove|Fredrik Backman",
    "Bajo la misma estrella|John Green",
    "La chica del tren|Paula Hawkins",
    "Yo antes de ti|Jojo Moyes",
    "Proyecto Hail Mary|Andy Weir",
    "La lección de August|Raquel J. Palacio",
    "El jilguero|Donna Tartt",
    "Balada de pájaros cantores y serpientes|Suzanne Collins",
    "Los años de peregrinación del chico sin color|Haruki Murakami",
    "La chica salvaje|Delia Owens",
    "Fuego y sangre|George R. R. Martin"
  ],
  pt: [
    "Insurgente|Veronica Roth",
    "A Man Called Ove|Fredrik Backman",
    "The Fault in Our Stars|John Green",
    "The Girl on the Train|Paula Hawkins",
    "Me Before You|Jojo Moyes",
    "And the Mountains Echoed|Khaled Hosseini",
    "Project Hail Mary|Andy Weir",
    "Extraordinário|R. J. Palacio",
    "O Pintassilgo|Donna Tartt",
    "The Ballad of Songbirds and Snakes|Suzanne Collins",
    "Where the Crawdads Sing|Delia Owens",
    "Fire & Blood|George R. R. Martin"
  ],
  fr: [
    "Divergente 2|Veronica Roth",
    "Vieux, râleur et suicidaire : La vie selon Ove|Fredrik Backman",
    "Nos Étoiles contraires|John Green",
    "La Fille du train|Paula Hawkins",
    "Avant toi|Jojo Moyes",
    "Ainsi résonne l'écho infini des montagnes|Khaled Hosseini",
    "Projet Dernière Chance|Andy Weir",
    "Wonder|Raquel J. Palacio",
    "Le Chardonneret|Donna Tartt",
    "La Ballade du serpent et de l'Oiseau chanteur|Suzanne Collins",
    "Là où chantent les écrevisses|Delia Owens",
    "Feu et Sang|George R. R. Martin"
  ],
  de: [
    "Die Bestimmung - Tödliche Wahrheit|Veronica Roth",
    "Ein Mann namens Ove|Fredrik Backman",
    "Das Schicksal ist ein mieser Verräter|John Green",
    "Girl on the Train|Paula Hawkins",
    "Ein ganzes halbes Jahr|Jojo Moyes",
    "Traumsammler|Khaled Hosseini",
    "Der Astronaut|Andy Weir",
    "Wunder|Raquel J. Palacio",
    "Der Distelfink|Donna Tartt",
    "Die Tribute von Panem X – Das Lied von Vogel und Schlange|Suzanne Collins",
    "Der Gesang der Flusskrebse|Delia Owens",
    "Fire & Blood|George R. R. Martin"
  ],
  it: [
    "Insurgent|Veronica Roth",
    "A Man Called Ove|Fredrik Backman",
    "Colpa delle stelle|John Green",
    "La ragazza del treno|Paula Hawkins",
    "Io prima di te (romanzo)|Jojo Moyes",
    "E l'eco rispose|Khaled Hosseini",
    "Project Hail Mary|Andy Weir",
    "Wonder|R. J. Palacio",
    "Il cardellino|Donna Tartt",
    "Hunger Games: Ballata dell'usignolo e del serpente|Suzanne Collins",
    "La ragazza della palude|Delia Owens",
    "Fuoco e sangue|George R. R. Martin"
  ]
};
