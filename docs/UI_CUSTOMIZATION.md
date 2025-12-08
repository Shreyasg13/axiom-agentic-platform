# UI Branding Customization Guide

## ✅ Changes Made (Scale → Your Brand)

### 1. Page Title & Metadata
**File**: `agentex-ui/app/layout.tsx`
```tsx
// CHANGED FROM:
title: 'Agentex'
description: 'Scale Agents'

// CHANGED TO:
title: 'Axiom Gladiator | AI Agent Platform'
description: 'Production-grade multi-provider AI orchestration for Windows'
```

### 2. Custom Header Component
**File**: `agentex-ui/components/custom-header.tsx` (NEW)
- Shows your brand "Axiom Gladiator"
- Custom logo (AG initials in gradient)
- GitHub link (update with YOUR username)
- "by Your Name" attribution

### 3. Main UI Layout
**File**: `agentex-ui/components/agentex-ui-root.tsx`
- Added `<CustomHeader />` at top
- Adjusted layout padding (`pt-14` to accommodate header)

---

## 🎨 Further Customization Options

### Option A: Change Colors/Theme
Edit `agentex-ui/app/globals.css`:
```css
/* Find and modify CSS variables */
:root {
  --primary: 262.1 83.3% 57.8%; /* Purple gradient */
  --secondary: 220.9 39.3% 11%; /* Dark blue */
}
```

### Option B: Change Logo
Edit `agentex-ui/components/custom-header.tsx` line 13-15:
```tsx
// Replace initials with custom image
<img src="/logo.png" alt="Logo" className="h-8 w-8" />
```

### Option C: Update Footer/Attribution
Add to `custom-header.tsx` around line 30:
```tsx
<span className="text-xs text-muted-foreground">
  Built by [Your Name] | Portfolio Project
</span>
```

---

## 🚀 For Your New Repository

### What to Copy to Your Repo:

#### Keep These Modified Files:
```
your-repo/
├── agentex-ui/
│   ├── app/
│   │   └── layout.tsx (✅ Modified - your branding)
│   └── components/
│       ├── agentex-ui-root.tsx (✅ Modified - custom header)
│       └── custom-header.tsx (✅ NEW - your brand component)
```

#### Add to README:
```markdown
## 🎨 UI Customization

The UI includes custom branding:
- **Title**: "Axiom Gladiator | AI Agent Platform"
- **Custom Header**: Shows logo, brand name, and GitHub link
- **Easily Extensible**: Modify `components/custom-header.tsx` to change branding

### Changing the Brand
1. Edit `app/layout.tsx` - Update title/description
2. Edit `components/custom-header.tsx` - Change logo and text
3. Optionally edit `app/globals.css` - Modify color scheme
```

---

## 📸 For Interviews - What to Show

### Before/After Comparison:
1. **Before**: "Agentex" / "Scale Agents" (generic)
2. **After**: "Axiom Gladiator | AI Agent Platform" (YOUR brand)

### Talk Track:
> "I forked the Agentex UI and rebranded it for my use case. The header component is fully customizable - I added my GitHub link and attribution. This shows I can take existing tools and adapt them for specific business needs."

---

## 🔧 Quick Test

### See Your Changes:
```powershell
# Restart the UI (if running)
# In the UI terminal window, press Ctrl+C, then:
npm run dev
```

### Open Browser:
```
http://localhost:3000
```

### Verify:
- ✅ Browser tab shows "Axiom Gladiator | AI Agent Platform"
- ✅ Top of page shows custom header with "AG" logo
- ✅ Shows "Axiom Gladiator" and "Multi-Provider AI Platform"

---

## 🎯 Next Steps for Interview Repo

### 1. Update Custom Header (2 min)
Open `agentex-ui/components/custom-header.tsx`:
- Line 30: Replace `YOUR_USERNAME` with your GitHub username
- Line 37: Replace `Your Name` with your actual name

### 2. Add Logo (Optional - 5 min)
```powershell
# Add your logo to public folder
copy your-logo.png agentex-ui\public\logo.png
```

Then edit `custom-header.tsx`:
```tsx
<img 
  src="/logo.png" 
  alt="Axiom Gladiator" 
  className="h-8 w-8 rounded-md"
/>
```

### 3. Screenshot for README
- Take screenshot showing your branded UI
- Add to your new repo's README
- Shows "before/after" transformation

---

## 💡 Interview Talking Points

### Technical Customization Skills:
> "I customized the UI by modifying the layout metadata and creating a custom header component. This demonstrates my ability to work with React/Next.js component architecture and adapt existing codebases to specific branding requirements."

### Product Thinking:
> "While the Scale UI is excellent, I wanted to showcase this as my own portfolio project. I created a custom header that clearly attributes the work while maintaining the professional look needed for production use."

### Attention to Detail:
> "I ensured the branding is consistent across browser tabs, page titles, and the UI itself. Small touches like the gradient logo and GitHub link show polish that interviewers notice."

---

## 📋 Verification Checklist

Before interviews, verify:
- [ ] Browser tab shows "Axiom Gladiator | AI Agent Platform"
- [ ] Custom header visible at top of page
- [ ] Logo/initials displaying correctly
- [ ] GitHub link points to YOUR repository
- [ ] Name attribution shows YOUR name
- [ ] Color scheme looks professional
- [ ] Mobile-responsive (bonus if you test this)

---

## 🎬 Demo Script for Interviews

**"Let me show you the UI customization..." (30 seconds)**

1. Open browser to localhost:3000
2. Point to browser tab: "Custom title and description for SEO"
3. Point to header: "Created this custom header component"
4. Click GitHub link: "Links directly to my repository"
5. Show agent selection: "Integrates seamlessly with the orchestrator we saw earlier"

**Why this matters:**
- Shows you can work with existing codebases
- Demonstrates React/Next.js skills
- Proves attention to branding/UX details
- Easy to explain in under 1 minute

---

## 🔄 Reverting (If Needed)

If you want to revert to original Scale branding:

```powershell
cd D:\LLM\scale-agentex\agentex-ui
git checkout app/layout.tsx
git checkout components/agentex-ui-root.tsx
rm components/custom-header.tsx
```

---

**Status**: ✅ Branding customization complete!
**Time**: 2 minutes to implement
**Impact**: Professional, interview-ready UI
