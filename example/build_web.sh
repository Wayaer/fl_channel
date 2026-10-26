cd "$(dirname "$0")" || exit 1

set -e

rm -rf 'app/web'

echo "开始获取 packages 插件资源"

flutter pub get

echo "开始构建 web"

flutter build web --no-web-resources-cdn --base-href '/fl_channel/example/app/web/'

mkdir -p app
mv 'build/web' 'app/web'
