cd backend
npm run build
cd ..
git add .
git add -f backend/public/build
git commit -m "update: $(date)"
git push origin main
