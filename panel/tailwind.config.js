const colors = require('tailwindcss/colors');

const gray = {
    50: 'hsl(216, 33%, 97%)',
    100: 'hsl(214, 15%, 91%)',
    200: 'hsl(210, 16%, 82%)',
    300: 'hsl(211, 13%, 65%)',
    400: '#9eacba',
    500: '#6f8496',
    600: '#4a6072',
    700: '#38495a',
    800: '#252e3b',
    900: '#1b232e',
};

module.exports = {
    content: [
        './resources/scripts/**/*.{js,ts,tsx}',
    ],
    theme: {
        extend: {
            fontFamily: {
                header: ['"IBM Plex Sans"', '"Roboto"', 'system-ui', 'sans-serif'],
            },
            colors: {
                black: '#161d27',
                blue: {
                    50: '#eaf4fb', 100: '#cde5f4', 200: '#a6d0ea', 300: '#74b6dd',
                    400: '#4a9fce', 500: '#3c8dbc', 600: '#337ba7', 700: '#2b6a90',
                    800: '#245778', 900: '#1d465f',
                },
                // "primary" and "neutral" are deprecated, prefer the use of "blue" and "gray"
                // in new code.
                primary: {
                    50: '#eaf4fb', 100: '#cde5f4', 200: '#a6d0ea', 300: '#74b6dd',
                    400: '#4a9fce', 500: '#3c8dbc', 600: '#337ba7', 700: '#2b6a90',
                    800: '#245778', 900: '#1d465f',
                },
                gray: gray,
                neutral: gray,
                cyan: {
                    50: '#eaf4fb', 100: '#cde5f4', 200: '#a6d0ea', 300: '#74b6dd',
                    400: '#67b7e5', 500: '#3c8dbc', 600: '#337ba7', 700: '#2b6a90',
                    800: '#245778', 900: '#1d465f',
                },
            },
            fontSize: {
                '2xs': '0.625rem',
            },
            transitionDuration: {
                250: '250ms',
            },
            borderColor: theme => ({
                default: theme('colors.neutral.400', 'currentColor'),
            }),
        },
    },
    plugins: [
        require('@tailwindcss/line-clamp'),
        require('@tailwindcss/forms')({
            strategy: 'class',
        }),
    ]
};
