const eventEmitter = require('../events');
const { sleep } = require('../util');

module.exports = async (name) => {
  await sleep(2000);
  return true;
};
