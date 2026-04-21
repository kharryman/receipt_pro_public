var fs = require('fs');
const currentDirectory = process.cwd();
const doIt = function () {
    fs.readdir("../peglist_maker/assets/i18n", (err, files) => {
        var transFile = "af", transFiles = [], fileSplit = [];
        var numTrans = 0;
        files.forEach(file => {
            fileSplit = file.split(".");
            if (fileSplit.slice(-1)[0] === "json") {
                numTrans++;
                //console.log("FILE:" + file);
                fileSplit.pop();
                transFile = fileSplit.join(".");
                console.log("transFile = " + transFile);
                transFiles.push(transFile);
            }
        });
        console.log("got transFiles = " + transFiles);
        for (var i = 0; i < transFiles.length; i++) {
            const filePath = currentDirectory + "/assets/i18n/" + transFiles[i] + ".json";
            if (!fs.existsSync(filePath)) {
                fs.writeFileSync(filePath, '{}', 'utf8');
                console.log('File created:', transFiles[i] + ".json");
            } else {
                console.log('File already exists:', transFiles[i] + ".json");
            }
        }
    });
}

doIt();