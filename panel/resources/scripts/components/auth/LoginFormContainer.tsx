import React, { forwardRef } from 'react';
import { Form } from 'formik';
import styled from 'styled-components/macro';
import FlashMessageRender from '@/components/FlashMessageRender';
import tw from 'twin.macro';

type Props = React.DetailedHTMLProps<React.FormHTMLAttributes<HTMLFormElement>, HTMLFormElement> & {
    title?: string;
};

const Container = styled.div`
    ${tw`w-full mx-auto px-4`};
    max-width: 340px;
`;

const Card = styled.div`
    background: linear-gradient(160deg, #12203c 0%, #0b1730 100%);
    border: 1px solid rgba(59, 130, 246, 0.25);
    box-shadow: 0 14px 32px rgba(3, 10, 26, 0.55);
    ${tw`w-full rounded-lg p-5`};
    border-top: 3px solid #3b82f6;

    input {
        ${tw`text-sm`};
        padding-top: 0.5rem;
        padding-bottom: 0.5rem;
    }

    label {
        ${tw`text-xs`};
    }

    button {
        ${tw`text-sm`};
        padding-top: 0.6rem !important;
        padding-bottom: 0.6rem !important;
    }
`;

export default forwardRef<HTMLFormElement, Props>(({ title, ...props }, ref) => (
    <Container>
        {title && (
            <div css={tw`text-center py-2`}>
                <h2 css={tw`text-lg text-neutral-100 font-medium`}>{title}</h2>
                <p css={tw`text-xs text-neutral-400 mt-1`}>Sign in to manage your servers</p>
            </div>
        )}
        <FlashMessageRender css={tw`mb-2 px-1`} />
        <Form {...props} ref={ref}>
            <Card>
                <div css={tw`w-full`}>{props.children}</div>
            </Card>
        </Form>
        <p css={tw`text-center text-neutral-500 text-xs mt-3`}>
            &copy; 2015 - {new Date().getFullYear()}&nbsp;KeztraviaMC
        </p>
    </Container>
));
