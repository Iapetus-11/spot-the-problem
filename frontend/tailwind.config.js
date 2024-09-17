/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        cerulean: {
          base: '#0081A7',
        },
        verdigris: {
          base: '#00AFB9',
        },
        egg: {
          base: '#FDFCDC',
        },
        peach: {
          'base': '#FED9B7',
        },
        bittersweet: {
          'base': '#F07167'
        }
      }
    },
  },
  plugins: [],
}