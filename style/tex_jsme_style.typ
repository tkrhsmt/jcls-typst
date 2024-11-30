/* --------------------------------------------------
             TYPST JSME BIB STYLE FILE
  file: tex_jsme_style.typ
  author: T.Hashimoto
-------------------------------------------------- */

// IMPORT PACKAGE
#import "@preview/unichar:0.3.0" : *

// --------------------------------------------------
//  FUNCTION
// --------------------------------------------------

//入力された文字列が全て空白文字が判別する関数
#let all_space(str) = {
  for value in str.clusters(){
    if value != " "{
      return true
    }
  }
  return false
}

//入力された文字列の前後の空白を削除する関数
#let remove_space(str) = {
  let output = str

  if str != "" and all_space(str){
    while output.first() == " "{
      output = output.slice(1, output.len())
    }
    while output.last() == " "{
      output = output.slice(0, output.len() - 1)
    }
  }

  return output
}

//改行を削除する関数
#let bibtex_remove_break(bib_arr) = {
  let output = ""
  for value in bib_arr{
    output += remove_space(value)
  }
  return output
}

#let bibstr_split_brace(bib_str) = {
  let output = ()
  let brace = 0
  let str = bib_str.clusters()
  let output_str = ""

  for val in str{
    if val == "{" and brace == 0{
      brace += 1
    }
    else if val == "{" and brace != 0{
      brace += 1
      output_str += val
    }
    else if val == "}" and brace == 1{
      brace -= 1
      output.push(output_str)
      output_str = ""
    }
    else if val == "}" and brace != 1{
      brace -= 1
      output_str += val
    }
    else{
      output_str += val
    }
  }

  return output
}

#let check_japanese_tex_str(str) = {
  let arr = str.clusters()
  let tmp = ""
  for value in arr{
    tmp = codepoint(value).block.name
    if tmp == "Hiragana" or tmp == "Katakana" or tmp == "CJK Unified Ideographs" or tmp == "Halfwidth and Fullwidth Forms"{
      return true
    }
  }
  return false
}

#let check_japanese_tex(bib_list) = {
  let output = false
  let bib_arr = bib_list.pairs()

  for value in bib_arr{
    let tmp = value.at(1)
    if check_japanese_tex_str(tmp){
      output = true
    }
  }
  return output
}

// --------------------------------------------------

#let content_to_string_tex(bibtex) = {
  let output = ""
  let bibtex_arr = bibtex.children

  for value in bibtex_arr{
    if value.has("text"){
      output += value.text
    }
    else if value.has("target"){//label
      let tmp = str(value.target)
      output += "@" + tmp
    }
    else if value.has("dest"){//url
      output += value.dest
    }
    else if value == [ ]{//空白文字
      output += " "
    }
  }

  return output
}

#let make_bib_list_tex(bibtex) = {

  let bibtex2 = content_to_string_tex(bibtex)

  let bib_arr = bibtex2.split("\n")//改行で区切る
  let bib_str = bibtex_remove_break(bib_arr)//改行を削除

  //bib_typeを取得
  let bib_type = bib_str.slice(1, bib_str.position("{"))
  bib_str = bib_str.slice(bib_str.position("{") + 1, bib_str.len())
  //bib_labelを取得
  let bib_label = bib_str.slice(0, bib_str.position(","))
  bib_str = bib_str.slice(bib_str.position(",") + 1, bib_str.len())
  let output = (type: bib_type)
  output.insert("label", bib_label)

  bib_arr = bibstr_split_brace(bib_str)//,で区切る

  for value in bib_arr{
    let bib = value.split("=")
    if bib.len() == 2{
      if all_space(bib.at(0)) and all_space(bib.at(1)){

        let key = remove_space(bib.at(0))//keyを取得
        if key.first() == ","{//keyの最初が,の場合，取り除く
          key = key.slice(1, key.len())
        }
        key = remove_space(key)//keyを取得
        let cont = remove_space(bib.at(1))//contを取得
        if key != "" and cont != ""{
          output.insert(key, cont)
        }
      }
    }
    else if bib.len() > 2{
      let key = remove_space(bib.at(0))//keyを取得
      if key.first() == ","{//keyの最初が,の場合，取り除く
        key = key.slice(1, key.len())
      }
      key = remove_space(key)//keyを取得
      let tmp = ""
      let i = 1
      while i < bib.len(){
        tmp += bib.at(i) + "="
        i += 1
      }
      tmp = tmp.slice(0, tmp.len() - 1)
      let cont = remove_space(tmp)//contを取得
      if key != "" and cont != ""{
        output.insert(key, cont)
      }
    }

  }

  return output
}

// --------------------------------------------------

#let remove_brace(str, is_japanese) = {

  if str == "" {return ""}
  let output = ""
  let title_arr = str.split("{")//{}で区切る
  let first = true

  if is_japanese {
    output =  str
    return output
  }
  else{

      for value in title_arr{

      let arr = value.split("}")
      if arr.len() == 2{//{}が存在する場合
        output += arr.at(0) + lower(arr.at(1))
      }
      else{//{}が存在しない場合
        if first and arr.at(0) != ""{
          output += upper(arr.at(0).first()) + lower(arr.at(0).slice(1, arr.at(0).len()))
        }
        else{
          output += lower(arr.at(0))
        }
      }
      first = false
    }
  }

  return output
}

#let make_tex_author(bib_list, is_japanese) = {

  let author_str = bib_list.at("author", default: "")
  if author_str == "" {return ""}
  let author_arr = author_str.split(" and ")
  let output = ""
  let author_num = author_arr.len()

  if author_str.first() == "{" and author_str.last() == "}"{//全体が{}で囲まれている場合
    let tmp = author_str.slice(1, author_str.len() - 1)
    if not(tmp.contains("{")) and not(tmp.contains("}")){
      return tmp + ", "
    }
  }

  let i = 0
  for value in author_arr{
    let author = remove_brace(value, is_japanese)
    author = author.split(",")
    if author.len() == 1{
      output += author.at(0) + ", "
    }
    else{
      if is_japanese{
        if author.at(1) == " "{
          output += remove_space(author.at(0)) + ", "
        }else{
          output += remove_space(author.at(0)) + remove_space(author.at(1)) + ", "
        }
      }
      else{
        if i == author_num - 2{
          output += remove_space(author.at(0)) + ", "
          let spl_space = author.at(1).split(" ")
          for val in spl_space{
            if all_space(val){
              output += upper(val.first()) + ". "
            }
          }
          output += "and "
        }
        else{
          output += remove_space(author.at(0)) + ", "
          let spl_space = author.at(1).split(" ")
          for val in spl_space{
            if all_space(val){
              output += upper(val.first()) + ". "
            }
          }
          output = output.slice(0, output.len() - 1) + ", "
        }
      }
    }
    i += 1
  }

  if is_japanese == false{//英語文献の場合は，空白を削除してカンマを挿入
     //output = output.slice(0, output.len() - 1) + ", "
  }

  return output
}

#let make_tex_manual_author(bib_list, is_japanese) = {

  let author_str = bib_list.at("author", default: "")
  if author_str == "" {return ""}
  let author_arr = author_str.split(" and ")
  let output = ""
  let author_num = author_arr.len()

  let i = 0
  for value in author_arr{
    if is_japanese{
        output += value + ", "
      }
      else{
        if i == author_num - 2{
          output += value + " and "
        }
        else{
          output += value + ", "
        }
      }
    i += 1
  }

  return output
}


#let make_tex_title(bib_list, is_japanese) = {

  let title_str = bib_list.at("title", default: "")
  if title_str == "" {return ""}

  return  remove_brace(title_str, is_japanese) + ", "
}

#let make_tex_year(bib_list, output_str) = {
  let year_str = bib_list.at("year", default: "")
  let output = ""
  let year_first = -1
  let year_last = -1

  if year_str != "" and output_str != ""{

    output += output_str.slice(0, output_str.len() - 2) + " ("
    year_first = output.len()
    output += year_str
    year_last = output.len()
    output += "), "

  }
  else{
    output = output_str
  }
  return (output, year_first, year_last)
}

#let make_tex_page(bib_list) = {
  let page_str = bib_list.at("pages", default: "")
  if page_str == "" {return ""}

  let output = ""

  let page_arr = page_str.split("–")
  if page_arr.len() == 2{
    output = "pp. " + page_arr.at(0) + "–" + page_arr.at(1) + ", "
  }else{
    output = "p. " + page_str + ", "
  }
  return output
}

// --------------------------------------------------
// JOUR FUNCTION
// --------------------------------------------------

//article typeの場合のtex出力
#let jsme_tex_type_article(bib_list, is_japanese) = {

  let output_str = ""

  // 著者名を取得
  output_str += make_tex_author(bib_list, is_japanese)
  // タイトルを取得
  output_str +=  make_tex_title(bib_list, is_japanese)
  // ジャーナル名を取得
  let tmp = bib_list.at("journal", default: "")
  if tmp != ""{
    output_str += tmp + ", "
  }
  // 巻を取得
  tmp = bib_list.at("volume", default: "")
  if tmp != ""{
    output_str += "Vol. " + tmp + ", "
  }
  // 号を取得
  tmp = bib_list.at("number", default: "")
  if tmp != ""{
    output_str += "No. " + tmp + ", "
  }
  // 年を取得
  tmp = make_tex_year(bib_list, output_str)
  output_str = tmp.at(0)
  let year_first = tmp.at(1)
  let year_last = tmp.at(2)
  // ページを取得
  output_str += make_tex_page(bib_list)
  // ノートを取得
  tmp = bib_list.at("note", default: "")
  if tmp != ""{
    output_str += tmp + ", "
  }

  //ピリオドの削除
  if output_str.len() > 2{
    output_str = output_str.slice(0, output_str.len() - 2) + "."
  }

  return (output_str, (year_first, year_last))
}

// --------------------------------------------------

//book typeの場合のtex出力
#let jsme_tex_type_book(bib_list, is_japanese) = {

  let output_str = ""

  // 著者名を取得
  output_str += make_tex_author(bib_list, is_japanese)
  // タイトルを取得
  output_str +=  make_tex_title(bib_list, is_japanese)
  // 巻を取得
  let tmp = bib_list.at("publisher", default: "")
  if tmp != ""{
    output_str +=  tmp + ", "
  }
  // 年を取得
  tmp = make_tex_year(bib_list, output_str)
  output_str = tmp.at(0)
  let year_first = tmp.at(1)
  let year_last = tmp.at(2)
  // ノートを取得
  tmp = bib_list.at("note", default: "")
  if tmp != ""{
    output_str += tmp + ", "
  }

  //ピリオドの削除
  if output_str.len() > 2{
    output_str = output_str.slice(0, output_str.len() - 2) + "."
  }

  return (output_str, (year_first, year_last))
}

// --------------------------------------------------

//booklet typeの場合のtex出力
#let jsme_tex_type_booklet(bib_list, is_japanese) = {

  let output_str = ""

  // 著者名を取得
  output_str += make_tex_author(bib_list, is_japanese)
  // タイトルを取得
  output_str +=  make_tex_title(bib_list, is_japanese)
  // 巻を取得
  let tmp = bib_list.at("howpublished", default: "")
  if tmp != ""{
    output_str +=  tmp + ", "
  }
  // 年を取得
  tmp = make_tex_year(bib_list, output_str)
  output_str = tmp.at(0)
  let year_first = tmp.at(1)
  let year_last = tmp.at(2)
  // ノートを取得
  tmp = bib_list.at("note", default: "")
  if tmp != ""{
    output_str += tmp + ", "
  }

  //ピリオドの削除
  if output_str.len() > 2{
    output_str = output_str.slice(0, output_str.len() - 2) + "."
  }

  return (output_str, (year_first, year_last))
}

// --------------------------------------------------

//inbook typeの場合のtex出力
#let jsme_tex_type_inbook(bib_list, is_japanese) = {

  let output_str = ""

  // 著者名を取得
  output_str += make_tex_author(bib_list, is_japanese)
  // タイトルを取得
  output_str +=  make_tex_title(bib_list, is_japanese)
  // 巻を取得
  let tmp = bib_list.at("publisher", default: "")
  if tmp != ""{
    output_str +=  tmp + ", "
  }
  // 年を取得
  tmp = make_tex_year(bib_list, output_str)
  output_str = tmp.at(0)
  let year_first = tmp.at(1)
  let year_last = tmp.at(2)
  // ページを取得
  output_str += make_tex_page(bib_list)
  // ノートを取得
  tmp = bib_list.at("note", default: "")
  if tmp != ""{
    output_str += tmp + ", "
  }

  //ピリオドの削除
  if output_str.len() > 2{
    output_str = output_str.slice(0, output_str.len() - 2) + "."
  }

  return (output_str, (year_first, year_last))
}

// --------------------------------------------------

//incollection typeの場合のtex出力
#let jsme_tex_type_incollection(bib_list, is_japanese) = {

  let output_str = ""

  // 著者名を取得
  output_str += make_tex_author(bib_list, is_japanese)
  // タイトルを取得
  output_str +=  make_tex_title(bib_list, is_japanese)
  // 本のタイトルを取得
  let tmp = bib_list.at("booktitle", default: "")
  if tmp != ""{
    output_str +=  tmp + ", "
  }
  // 巻を取得
  tmp = bib_list.at("publisher", default: "")
  if tmp != ""{
    output_str +=  tmp + ", "
  }
  // 年を取得
  tmp = make_tex_year(bib_list, output_str)
  output_str = tmp.at(0)
  let year_first = tmp.at(1)
  let year_last = tmp.at(2)
  // ノートを取得
  tmp = bib_list.at("note", default: "")
  if tmp != ""{
    output_str += tmp + ", "
  }

  //ピリオドの削除
  if output_str.len() > 2{
    output_str = output_str.slice(0, output_str.len() - 2) + "."
  }

  return (output_str, (year_first, year_last))
}

// --------------------------------------------------

//inproceedings typeの場合のtex出力
#let jsme_tex_type_inproceedings(bib_list, is_japanese) = {

  let output_str = ""

  // 著者名を取得
  output_str += make_tex_author(bib_list, is_japanese)
  // タイトルを取得
  output_str +=  make_tex_title(bib_list, is_japanese)
  // 本のタイトルを取得
  let tmp = bib_list.at("booktitle", default: "")
  if tmp != ""{
    output_str +=  tmp + ", "
  }
  // 年を取得
  tmp = make_tex_year(bib_list, output_str)
  output_str = tmp.at(0)
  let year_first = tmp.at(1)
  let year_last = tmp.at(2)
  // ノートを取得
  tmp = bib_list.at("note", default: "")
  if tmp != ""{
    output_str += tmp + ", "
  }

  //ピリオドの削除
  if output_str.len() > 2{
    output_str = output_str.slice(0, output_str.len() - 2) + "."
  }

  return (output_str, (year_first, year_last))
}

// --------------------------------------------------

//manual typeの場合のtex出力
#let jsme_tex_type_manual(bib_list, is_japanese) = {

  let output_str = ""

  // 著者名を取得
  output_str += make_tex_manual_author(bib_list, is_japanese)
  // タイトルを取得
  output_str +=  make_tex_title(bib_list, is_japanese)
  // 年を取得
  let tmp = make_tex_year(bib_list, output_str)
  output_str = tmp.at(0)
  let year_first = tmp.at(1)
  let year_last = tmp.at(2)
  // ノートを取得
  tmp = bib_list.at("note", default: "")
  if tmp != ""{
    output_str += tmp + ", "
  }

  //ピリオドの削除
  if output_str.len() > 2{
    output_str = output_str.slice(0, output_str.len() - 2) + "."
  }

  return (output_str, (year_first, year_last))
}

// --------------------------------------------------

//mastersthesis typeの場合のtex出力
#let jsme_tex_type_mastersthesis(bib_list, is_japanese) = {

  let output_str = ""

  // 著者名を取得
  output_str += make_tex_author(bib_list, is_japanese)
  // タイトルを取得
  output_str +=  make_tex_title(bib_list, is_japanese)
  // 学位を取得
  let tmp = bib_list.at("school", default: "")
  if tmp != ""{
    if is_japanese{
      output_str +=  tmp + "修士論文, "
    }
    else{
      output_str += "Master's thesis, " + tmp + ", "
    }
  }
  // 年を取得
  tmp = make_tex_year(bib_list, output_str)
  output_str = tmp.at(0)
  let year_first = tmp.at(1)
  let year_last = tmp.at(2)
  // ノートを取得
  tmp = bib_list.at("note", default: "")
  if tmp != ""{
    output_str += tmp + ", "
  }

  //ピリオドの削除
  if output_str.len() > 2{
    output_str = output_str.slice(0, output_str.len() - 2) + "."
  }

  return (output_str, (year_first, year_last))
}

// --------------------------------------------------

//misc typeの場合のtex出力
#let jsme_tex_type_misc(bib_list, is_japanese) = {

  let output_str = ""

  // 著者名を取得
  output_str += make_tex_author(bib_list, is_japanese)
  // タイトルを取得
  output_str +=  make_tex_title(bib_list, is_japanese)
  // 巻を取得
  if bib_list.at("archivePrefix", default: "") == "arXiv" and bib_list.at("eprint", default: "") != ""{
    output_str += "arXiv: " + bib_list.at("eprint") + ", "
  }
  else{
    let tmp = bib_list.at("howpublished", default: "")
    if tmp != ""{
      output_str +=  tmp + ", "
    }
  }
  // 年を取得
  let tmp = make_tex_year(bib_list, output_str)
  output_str = tmp.at(0)
  let year_first = tmp.at(1)
  let year_last = tmp.at(2)
  // ノートを取得
  tmp = bib_list.at("note", default: "")
  if tmp != ""{
    output_str += tmp + ", "
  }

  //ピリオドの削除
  if output_str.len() > 2{
    output_str = output_str.slice(0, output_str.len() - 2) + "."
  }

  return (output_str, (year_first, year_last))
}

// --------------------------------------------------

//online typeの場合のtex出力
#let jsme_tex_type_online(bib_list, is_japanese) = {

  let output_str = ""

  // 著者名を取得
  output_str += make_tex_author(bib_list, is_japanese)
  // タイトルを取得
  output_str +=  make_tex_title(bib_list, is_japanese)
  // URLを取得
  let tmp = bib_list.at("url", default: "")
  if tmp != ""{
    if is_japanese{
      output_str += "<" + tmp + ">, "
    }
    else{
      output_str += "available from <" + tmp + ">, "
    }
  }
  // 参照日を取得
  let tmp = bib_list.at("access", default: "")
  if tmp != ""{
    if is_japanese{
      output_str += "(参照日 " + tmp + "), "
    }
    else{
      output_str += "(accessed on " + tmp + "), "
    }
  }
  // ノートを取得
  tmp = bib_list.at("note", default: "")
  if tmp != ""{
    output_str += tmp + ", "
  }

  //ピリオドの削除
  if output_str.len() > 2{
    output_str = output_str.slice(0, output_str.len() - 2) + "."
  }

  return (output_str, (-1, -1))
}

// --------------------------------------------------

//phdthesis typeの場合のtex出力
#let jsme_tex_type_phdthesis(bib_list, is_japanese) = {

  let output_str = ""

  // 著者名を取得
  output_str += make_tex_author(bib_list, is_japanese)
  // タイトルを取得
  output_str +=  make_tex_title(bib_list, is_japanese)
  // 学位を取得
  let tmp = bib_list.at("school", default: "")
  if tmp != ""{
    if is_japanese{
      output_str +=  tmp + "博士論文, "
    }
    else{
      output_str += "Ph.D. dissertation, " + tmp + ", "
    }
  }
  // 年を取得
  tmp = make_tex_year(bib_list, output_str)
  output_str = tmp.at(0)
  let year_first = tmp.at(1)
  let year_last = tmp.at(2)
  // ノートを取得
  tmp = bib_list.at("note", default: "")
  if tmp != ""{
    output_str += tmp + ", "
  }

  //ピリオドの削除
  if output_str.len() > 2{
    output_str = output_str.slice(0, output_str.len() - 2) + "."
  }

  return (output_str, (year_first, year_last))
}

// --------------------------------------------------

//proceedings typeの場合のtex出力
#let jsme_tex_type_proceedings(bib_list, is_japanese) = {

  let output_str = ""

  // タイトルを取得
  output_str +=  make_tex_title(bib_list, is_japanese)
  // 年を取得
  let tmp = make_tex_year(bib_list, output_str)
  output_str = tmp.at(0)
  let year_first = tmp.at(1)
  let year_last = tmp.at(2)
  // ノートを取得
  tmp = bib_list.at("note", default: "")
  if tmp != ""{
    output_str += tmp + ", "
  }

  //ピリオドの削除
  if output_str.len() > 2{
    output_str = output_str.slice(0, output_str.len() - 2) + "."
  }

  return (output_str, (year_first, year_last))
}

// --------------------------------------------------

//techreport typeの場合のtex出力
#let jsme_tex_type_techreport(bib_list, is_japanese) = {

  let output_str = ""

  // 著者名を取得
  output_str += make_tex_author(bib_list, is_japanese)
  // タイトルを取得
  output_str +=  make_tex_title(bib_list, is_japanese)
  // 巻を取得
  let tmp = bib_list.at("institution", default: "")
  if tmp != ""{
    output_str +=  tmp + ", "
  }
  // 年を取得
  tmp = make_tex_year(bib_list, output_str)
  output_str = tmp.at(0)
  let year_first = tmp.at(1)
  let year_last = tmp.at(2)
  // ノートを取得
  tmp = bib_list.at("note", default: "")
  if tmp != ""{
    output_str += tmp + ", "
  }

  //ピリオドの削除
  if output_str.len() > 2{
    output_str = output_str.slice(0, output_str.len() - 2) + "."
  }

  return (output_str, (year_first, year_last))
}

// --------------------------------------------------


//unpublished typeの場合のtex出力
#let jsme_tex_type_unpublished(bib_list, is_japanese) = {

  let output_str = ""

  // 著者名を取得
  output_str += make_tex_author(bib_list, is_japanese)
  // タイトルを取得
  output_str +=  make_tex_title(bib_list, is_japanese)
  // 年を取得
  let tmp = make_tex_year(bib_list, output_str)
  output_str = tmp.at(0)
  let year_first = tmp.at(1)
  let year_last = tmp.at(2)
  // ノートを取得
  tmp = bib_list.at("note", default: "")
  if tmp != ""{
    output_str += tmp + ", "
  }

  //ピリオドの削除
  if output_str.len() > 2{
    output_str = output_str.slice(0, output_str.len() - 2) + "."
  }

  return (output_str, (year_first, year_last))
}

#let make_tex_author_cite(bib_list, is_japanese) = {

  let author = bib_list.at("author", default: "")
  let author_arr = author.split(" and ")
  let output = ""
  let author_num = author_arr.len()

  if author_num == 1{
    let tmp = author_arr.at(0).split(",")
    if is_japanese{
      output += tmp.at(0)
    }
    else{
      output += remove_brace(tmp.at(0), is_japanese)
    }
  }
  else if author_num == 2{
    let author1 = author_arr.at(0).split(",")
    let author2 = author_arr.at(1).split(",")
    if is_japanese{
      output += author1.at(0) + ", " + author2.at(0)
    }
    else{
      output += remove_brace(author1.at(0), is_japanese) + " and " + remove_brace(author2.at(0),  is_japanese)
    }
  }
  else if author_num > 2{
    let tmp = author_arr.at(0).split(",")
    if is_japanese{
      output += tmp.at(0) + "他"
    }
    else{
      output += remove_brace(tmp.at(0), is_japanese) + " et al."
    }
  }

  return output
}

// --------------------------------------------------
// AUTHOR FUNCTION
// --------------------------------------------------

#let jsme_tex_author(bib_list, is_japanese) = {

  let output_str = ""

  // 著者名を取得
  if bib_list.at("author", default: "") != ""{
    if bib_list.at("type") == "manual"{
      output_str += make_tex_manual_author(bib_list, is_japanese)
    }
    else{
      output_str += make_tex_author_cite(bib_list, is_japanese)
    }
  }
  else if bib_list.at("editor", default: "") != ""{
    output_str += bib_list.at("editor", default: "")
  }
  else if bib_list.at("title", default: "") != ""{
    output_str += bib_list.at("title", default: "")
  }

  return output_str
}

#let jsme_tex_year(bib_list) = {

  // 年を取得
  let output = bib_list.at("year", default: "")
  if output != ""{
    return output
  }

  return ""
}

#let jsme_tex_yomi(bib_list, is_japanese) = {

  let output = ""
  if is_japanese{//日本語文献の場合は，yomiを取得

    let yomi = bib_list.at("yomi", default: "")
    if yomi != ""{//yomiがある場合は，yomiを取得
      output = yomi
    }
    else{//yomiがない場合は，著者名から取得
      output = bib_list.at("author", default: "")
      output = remove_brace(output, is_japanese)
    }

  }
  else{//英語文献の場合は，著者名から取得
    output = bib_list.at("author", default: "")
    output = remove_brace(output, is_japanese)
  }

  if output == ""{//著者名がない場合は，editorを取得
    output = bib_list.at("editor", default: "")
    output = remove_brace(output, is_japanese)
  }

  if output == ""{//editorがない場合は，titleを取得
    output = bib_list.at("title", default: "")
    output = remove_brace(output, is_japanese)
  }

  return output
}



// --------------------------------------------------
//  MAIN FUNCTION
// --------------------------------------------------

#let from_tex_to_biblist(bibtex, lang: false) = {

  let bib_list = make_bib_list_tex(bibtex)

  //文献typeを取得
  let TYPE = bib_list.at("type")

  //日本語が含まれているかどうか
  let is_japanese = false
  if lang == false{
    is_japanese = check_japanese_tex(bib_list)
  }
  else{
    is_japanese = lang
  }

  let it_arr = ()
  if TYPE == "article"{
    it_arr = jsme_tex_type_article(bib_list, is_japanese)
  }
  else if TYPE == "book"{
    it_arr = jsme_tex_type_book(bib_list, is_japanese)
  }
  else if TYPE == "booklet"{
    it_arr = jsme_tex_type_booklet(bib_list, is_japanese)
  }
  else if TYPE == "inbook"{
    it_arr = jsme_tex_type_inbook(bib_list, is_japanese)
  }
  else if TYPE == "incollection"{
    it_arr = jsme_tex_type_incollection(bib_list, is_japanese)
  }
  else if TYPE == "inproceedings" or TYPE == "conference"{
    it_arr = jsme_tex_type_inproceedings(bib_list, is_japanese)
  }
  else if TYPE == "manual"{
    it_arr = jsme_tex_type_manual(bib_list, is_japanese)
  }
  else if TYPE == "mastersthesis"{
    it_arr = jsme_tex_type_mastersthesis(bib_list, is_japanese)
  }
  else if TYPE == "misc"{
    it_arr = jsme_tex_type_misc(bib_list, is_japanese)
  }
  else if TYPE == "online"{
    it_arr = jsme_tex_type_online(bib_list, is_japanese)
  }
  else if TYPE == "phdthesis"{
    it_arr = jsme_tex_type_phdthesis(bib_list, is_japanese)
  }
  else if TYPE == "proceedings"{
    it_arr = jsme_tex_type_proceedings(bib_list, is_japanese)
  }
  else if TYPE == "techreport"{
    it_arr = jsme_tex_type_techreport(bib_list, is_japanese)
  }
  else if TYPE == "unpublished"{
    it_arr = jsme_tex_type_unpublished(bib_list, is_japanese)
  }

  //著者名を取得
  let author = jsme_tex_author(bib_list, is_japanese)
  it_arr.insert(1, author)

  //年を取得
  let year = jsme_tex_year(bib_list)
  it_arr.insert(2, year)

  //ラベルを取得
  let label = label(bib_list.at("label", default: ""))
  it_arr.insert(3, label)

  //読みを取得
  let yomi = jsme_tex_yomi(bib_list, is_japanese)
  it_arr.insert(4, yomi)

  let i = 0
  for value in it_arr{
    if value == ""{
      it_arr.at(i) = none
    }
    i += 1
  }

  return it_arr
}
