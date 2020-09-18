for var in `ls vendor/bundle/ruby/2.5.0/gems/ | grep decidim`
do
cp ja_merged/${var:0:-7}_ja.yml ./vendor/bundle/ruby/2.5.0/gems/${var}/config/locales/ja.yml
done
