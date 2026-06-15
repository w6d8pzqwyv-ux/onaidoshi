// recommend.js —「いま世界で読まれている本」(全員に常に表示する独立コーナー)
// 同い年ロジックとは無関係。最新の人気書籍をアフィリンク付きで表示し購入導線にする。
// age は birth(生年月日)から毎回その場で計算するので、年が変わっても自動で正しい。
// proof(裏付け)は出典をWeb検索で確認済み(2026-06時点)。数字や受賞のない曖昧な本は載せない。
window.RECOMMEND = {
  books: [
    { title: "Fourth Wing", author: "Rebecca Yarros", birth: "1981-04-13",
      proof: { ja:"続編が初週270万部・NYT1位", en:"Sequel sold 2.7M in week one · #1 NYT", es:"La secuela vendió 2,7 M en su 1.ª semana · n.º1 NYT", pt:"A sequência vendeu 2,7 mi na 1ª semana · nº1 NYT", fr:"La suite : 2,7 M vendus la 1re semaine · n°1 NYT", de:"Fortsetzung: 2,7 Mio. in der 1. Woche · Nr.1 NYT", it:"Il seguito: 2,7 mln nella 1ª settimana · n.1 NYT" } },
    { title: "Lessons in Chemistry", author: "Bonnie Garmus", birth: "1957-04-18",
      proof: { ja:"全世界800万部超・Apple TV+でドラマ化", en:"8M+ copies sold · Apple TV+ series", es:"+8 millones de ejemplares · serie en Apple TV+", pt:"+8 milhões de cópias · série Apple TV+", fr:"+8 millions d'exemplaires · série Apple TV+", de:"über 8 Mio. verkauft · Apple TV+-Serie", it:"oltre 8 mln di copie · serie Apple TV+" } },
    { title: "Tomorrow, and Tomorrow, and Tomorrow", author: "Gabrielle Zevin", birth: "1977-10-24",
      proof: { ja:"全世界500万部超・39言語に翻訳", en:"5M+ copies · translated into 39 languages", es:"+5 millones · traducido a 39 idiomas", pt:"+5 milhões · traduzido em 39 idiomas", fr:"+5 millions · traduit en 39 langues", de:"über 5 Mio. · in 39 Sprachen übersetzt", it:"oltre 5 mln · tradotto in 39 lingue" } },
    { title: "Demon Copperhead", author: "Barbara Kingsolver", birth: "1955-04-08",
      proof: { ja:"ピューリッツァー賞2023・Oprah選書", en:"Pulitzer Prize 2023 · Oprah's Book Club", es:"Premio Pulitzer 2023 · Club de Lectura de Oprah", pt:"Prémio Pulitzer 2023 · Clube do Livro de Oprah", fr:"Prix Pulitzer 2023 · Club de lecture d'Oprah", de:"Pulitzer-Preis 2023 · Oprahs Buchclub", it:"Premio Pulitzer 2023 · Club del libro di Oprah" } },
    { title: "James", author: "Percival Everett", birth: "1956-12-22",
      proof: { ja:"ピューリッツァー賞＋全米図書賞2024", en:"Pulitzer Prize + National Book Award 2024", es:"Premio Pulitzer + National Book Award 2024", pt:"Prémio Pulitzer + National Book Award 2024", fr:"Prix Pulitzer + National Book Award 2024", de:"Pulitzer-Preis + National Book Award 2024", it:"Premio Pulitzer + National Book Award 2024" } },
    { title: "Prophet Song", author: "Paul Lynch", birth: "1977-05-09",
      proof: { ja:"ブッカー賞2023受賞", en:"Booker Prize 2023", es:"Premio Booker 2023", pt:"Booker Prize 2023", fr:"Booker Prize 2023", de:"Booker Prize 2023", it:"Booker Prize 2023" } },
    { title: "The Women", author: "Kristin Hannah", birth: "1960-09-25",
      proof: { ja:"2024年 全米No.1ベストセラー", en:"#1 US bestseller of 2024", es:"libro n.º1 en ventas de EE. UU. en 2024", pt:"nº1 em vendas nos EUA em 2024", fr:"n°1 des ventes aux États-Unis en 2024", de:"meistverkauftes US-Buch 2024", it:"libro più venduto negli USA nel 2024" } },
    { title: "Intermezzo", author: "Sally Rooney", birth: "1991-02-20",
      proof: { ja:"世界的No.1ベストセラー2024", en:"global #1 bestseller 2024", es:"bestseller n.º1 mundial 2024", pt:"bestseller nº1 mundial 2024", fr:"best-seller mondial n°1 2024", de:"weltweiter Nr.1-Bestseller 2024", it:"bestseller mondiale n.1 2024" } },
    { title: "The Midnight Library", author: "Matt Haig", birth: "1975-07-03",
      proof: { ja:"全世界1200万部超・英No.1", en:"12M+ copies sold · #1 Sunday Times", es:"+12 millones de ejemplares", pt:"+12 milhões de cópias", fr:"+12 millions d'exemplaires", de:"über 12 Mio. verkauft", it:"oltre 12 mln di copie" } },
    { title: "The Covenant of Water", author: "Abraham Verghese", birth: "1955-05-30",
      proof: { ja:"全世界200万部超・Oprah選書", en:"2M+ copies · Oprah's Book Club", es:"+2 millones · Club de Lectura de Oprah", pt:"+2 milhões · Clube do Livro de Oprah", fr:"+2 millions · Club de lecture d'Oprah", de:"über 2 Mio. · Oprahs Buchclub", it:"oltre 2 mln · Club del libro di Oprah" } },
    { title: "Yellowface", author: "R. F. Kuang", birth: "1996-05-29",
      proof: { ja:"Reese's Book Club選出・世界的ベストセラー", en:"Reese's Book Club · global bestseller", es:"Reese's Book Club · bestseller mundial", pt:"Reese's Book Club · bestseller mundial", fr:"Reese's Book Club · best-seller mondial", de:"Reese's Book Club · Weltbestseller", it:"Reese's Book Club · bestseller mondiale" } },
    { title: "The Seven Husbands of Evelyn Hugo", author: "Taylor Jenkins Reid", birth: "1983-12-20",
      proof: { ja:"NYTベストセラー120週超", en:"120+ weeks on the NYT bestseller list", es:"+120 semanas en la lista del NYT", pt:"+120 semanas na lista do NYT", fr:"+120 semaines au classement du NYT", de:"120+ Wochen auf der NYT-Bestsellerliste", it:"oltre 120 settimane nella classifica del NYT" } }
  ],
  ui: {
    ja: { heading:"📚 いま世界で読まれている本", age:(n)=>`この本を書いた著者は 現在${n}歳`, cta:"Amazonで見る →", amazon:"https://www.amazon.co.jp/s?tag=onaidoshi05-22&k=" },
    en: { heading:"📚 Read around the world right now", age:(n)=>`The author of this book is now ${n}`, cta:"View on Amazon →", amazon:"https://www.amazon.com/s?tag=onaidoshi20-20&k=" },
    es: { heading:"📚 Lo que el mundo lee ahora", age:(n)=>`Quien escribió este libro tiene ahora ${n} años`, cta:"Ver en Amazon →", amazon:"https://www.amazon.es/s?tag=onaidoshi-21&k=" },
    pt: { heading:"📚 O que o mundo lê agora", age:(n)=>`Quem escreveu este livro tem agora ${n} anos`, cta:"Ver na Amazon →", amazon:"https://www.amazon.com/s?tag=onaidoshi20-20&k=" },
    fr: { heading:"📚 Ce que le monde lit en ce moment", age:(n)=>`L'auteur de ce livre a aujourd'hui ${n} ans`, cta:"Voir sur Amazon →", amazon:"https://www.amazon.fr/s?tag=onaidoshi-21&k=" },
    de: { heading:"📚 Was die Welt gerade liest", age:(n)=>`Der Autor dieses Buches ist heute ${n}`, cta:"Auf Amazon ansehen →", amazon:"https://www.amazon.de/s?tag=onaidoshi-21&k=" },
    it: { heading:"📚 Ciò che il mondo legge ora", age:(n)=>`Chi ha scritto questo libro ha ora ${n} anni`, cta:"Vedi su Amazon →", amazon:"https://www.amazon.it/s?tag=onaidoshi-21&k=" }
  }
};

window.renderRecommend = function(lang, containerId) {
  const R = window.RECOMMEND;
  const el = document.getElementById(containerId);
  if (!R || !R.ui[lang] || !el) return;
  const ui = R.ui[lang];
  const b = R.books[Math.floor(Math.random() * R.books.length)];
  const bd = new Date(b.birth), now = new Date();
  let age = now.getFullYear() - bd.getFullYear();
  const m = now.getMonth() - bd.getMonth();
  if (m < 0 || (m === 0 && now.getDate() < bd.getDate())) age--;
  const q = encodeURIComponent(b.title + " " + b.author);
  const proof = b.proof[lang] || b.proof.en;
  el.innerHTML = `
    <div class="recobox">
      <p class="reco-h">${ui.heading}</p>
      <p class="reco-t">${b.title}</p>
      <p class="reco-a">${b.author}<span class="reco-proof"> — ${proof}</span></p>
      <p class="reco-age">✍ ${ui.age(age)}</p>
      <a class="reco-cta" href="${ui.amazon}${q}" target="_blank" rel="noopener">${ui.cta}</a>
    </div>`;
};
