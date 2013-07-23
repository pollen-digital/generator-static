var path = require('path'),
    util = require('util'),
    yeoman = require('yeoman-generator');

var prompts = [{
  name: 'projectName',
  message: 'What would you like to call your project?',
  default: 'myApp'
}];

var Generator = module.exports = function(args, options, config) {
  yeoman.generators.Base.apply(this, arguments);
  this.package = JSON.parse(this.readFileAsString(path.join(__dirname, '../package.json')));
  this.log.writeln('Generating from ' + 'Generator Static'.cyan + ' v' + this.package.version.cyan + '...');
  this.on('end', function() {
    this.installDependencies({ skipInstall: options['skip-install'] });
  });
};

util.inherits(Generator, yeoman.generators.NamedBase);

Generator.name = 'static';

Generator.prototype.askFor = function askFor() {
  var cb = this.async();
  this.prompt(prompts, function(props) {
    this.projectName = props.projectName;
    cb();
  }.bind(this));
};

Generator.prototype.app = function app() {
  this.directory('../skeleton', '.');
  this.template('_bower.json', 'bower.json');
  this.template('_package.json', 'package.json');
};
