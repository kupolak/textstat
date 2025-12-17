#!/bin/bash
# Script to deploy YARD documentation to gh-pages branch

set -e

echo "📚 Generating YARD documentation..."

# Generate documentation in temporary directory
yard doc --output-dir docs_tmp

# Stash any changes
git stash

# Switch to gh-pages branch
echo "🔀 Switching to gh-pages branch..."
git checkout gh-pages

# Remove old documentation files (except .git, .nojekyll)
echo "🗑️  Removing old documentation..."
find . -maxdepth 1 ! -name '.git' ! -name '.gitignore' ! -name '.nojekyll' ! -name 'docs_tmp' ! -name '.' -exec rm -rf {} +

# Move new documentation to root
echo "📦 Copying new documentation..."
mv docs_tmp/* .
rmdir docs_tmp

# Add all files
git add .

# Check if there are changes to commit
if git diff --staged --quiet; then
    echo "✅ No changes to commit"
else
    echo "💾 Committing changes..."
    git commit -m "Update documentation - $(date '+%Y-%m-%d %H:%M:%S')"
    
    echo "🚀 Pushing to gh-pages..."
    git push origin gh-pages
    
    echo "✨ Documentation deployed successfully!"
    echo "🌐 View at: https://kupolak.github.io/textstat"
fi

# Return to master branch
echo "🔙 Returning to master branch..."
git checkout master

# Restore stashed changes if any
git stash pop 2>/dev/null || true

echo "✅ Done!"
