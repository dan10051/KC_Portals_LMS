const gulp = require('gulp');
const spritesmith = require('gulp.spritesmith');
const sass = require('gulp-sass');
const autoprefixer = require('gulp-autoprefixer');
const sourcemaps = require('gulp-sourcemaps');
const csso = require('gulp-csso');

const rootFolder = '/admin/';
const template = 'default';
const ver = '1.0';

var templatePath = template + '/' + ver;

function sprite(f) {
    var spriteData =
        gulp.src('./src/' + templatePath + '/sprites/*.*')
            .pipe(spritesmith({
                imgName: 'sprite.png',
                cssName: '_sprite.scss',
                imgPath: rootFolder + 'templates/' + templatePath + '/css/imgs/sprite.png',
                padding: 2
            }));
    spriteData.img.pipe(gulp.dest('./templates/' + templatePath + '/css/imgs/'));
    spriteData.css.pipe(gulp.dest('./src/' + templatePath + '/scss/mixins/'));

    f();
}

exports.sprite = sprite;

function dev(f) {
    gulp.src('./src/' + templatePath + '/scss/*.scss')
        .pipe(sourcemaps.init())
        .pipe(sass())
        .on('error', function (error) {
            console.log(error.toString());
            this.emit('end')
        })
        .pipe(autoprefixer())
        .pipe(csso())
        .pipe(sourcemaps.write())
        .pipe(gulp.dest('./templates/default/1.0/css/'));

    f();
}

exports['css-dev'] = dev;

/* without sourcemap */
exports['css-build'] = function (f) {
    gulp.src('./src/' + templatePath + '/scss/*.scss')
        .pipe(sass())
        .pipe(autoprefixer())
        .pipe(csso())
        .pipe(gulp.dest('./templates/default/1.0/css/'));

    f();
};

function watch(f) {
    gulp.watch(['./src/' + templatePath + '/scss/*.scss', './src/' + templatePath + '/scss/*/*.scss'], dev);
    gulp.watch(['./src/' + templatePath + '/sprites/*.*'], sprite);

    f();
}

exports.watch = watch;
exports.default = watch;
