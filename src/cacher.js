const pathModule = require('node:path');
const fs = require('node:fs');

const api = new Map();

const cacheFile = (name) => {
  const filePath = pathModule.resolve(process.cwd(), process.env.API_PATH, name);
  const key = pathModule.basename(filePath, '.js');
  try {
    const libPath = require.resolve(filePath);
    delete require.cache[libPath];
  } catch (e) {
    console.error(e);
    return;
  }
  try {
    const method = require(filePath);
    api.set(key, method);
  } catch (e) {
    console.error(e);
    api.delete(key);
  }
};

const cacheFolder = (path = process.env.API_PATH) => {
  fs.readdir(pathModule.resolve(process.cwd(), path), (err, files) => {
    if (err) return;
    files.forEach(cacheFile);
  });
};

const watch = (path = process.env.API_PATH) => {
  fs.watch(pathModule.resolve(process.cwd(), path), (event, file) => {
    cacheFile(file);
  });
};

module.exports = {
  cacheFile,
  cacheFolder,
  watch,
  api,
};
