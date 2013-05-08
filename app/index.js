var path = require('path'),
    util = require('util'),
    yeoman = require('yeoman-generator');

var Generator = module.exports = function() {
  yeoman.generators.Base.apply(this, arguments);
  this.package = JSON.parse(this.readFileAsString(path.join(__dirname, '../package.json')));
  this.log.writeln('Generating from ' + 'Generator Static'.cyan + ' v' + this.package.version.cyan + '...');
};

util.inherits(Generator, yeoman.generators.NamedBase);

Generator.name = 'clientdev';

Generator.prototype.app = function app() {
  this.directory('.', '.');
  this.installDependencies();
};
