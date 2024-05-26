const fs = require('fs')
const path = require('path');
const argparse = require('/data/data/com.termux/files/usr/lib/node_modules/argparse')

const frame_list = [
	"A",
	"B",
	"C",
	"D",
	"E",
	"F",
	"G",
	"H",
	"I",
	"J",
	"K",
	"L",
	"M",
	"N",
	"O",
	"P",
	"Q",
	"R",
	"S",
	"T",
	"U",
	"V",
	"W",
	"X",
	"Y",
	"Z",
	"0",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"a",
	"b",
	"c",
	"d",
	"e",
	"f",
	"g",
	"h",
	"i",
	"j",
	"k",
	"l",
	"m",
	"n",
	"o",
	"p",
	"q",
	"r",
	"s",
	"t",
	"u",
	"v",
	"w",
	"x",
	"y",
	"z",
	"!",
	"@"
]

let parser = new argparse.ArgumentParser({
  description: 'rename files'
});

parser.add_argument('folder', { help: 'is da folder' });
parser.add_argument('name', { help: 'is da thing to rename it as' });

let args = parser.parse_args()

function getFiles(dir, files = []) {
  const fileList = fs.readdirSync(dir)
  for (const file of fileList) {
    const name = `${dir}/${file}`
    if (fs.statSync(name).isDirectory()) {
      getFiles(name, files)
    } else {
      files.push(name)
    }
  }
  files.sort()
  return files
}

const files = getFiles(path.basename(args.folder))
console.log(files)
