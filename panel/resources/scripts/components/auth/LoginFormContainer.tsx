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
    background: linear-gradient(150deg, #2b3644 0%, #212a35 100%);
    border: 1px solid #38495a;
    border-top: 3px solid #3c8dbc;
    box-shadow: 0 6px 18px rgba(0, 0, 0, 0.22);
    ${tw`w-full rounded-lg overflow-hidden`};
    transition: border-color 0.15s ease, box-shadow 0.15s ease;

    &:hover {
        border-color: #4a90bf;
        border-top-color: #67b7e5;
        box-shadow: 0 10px 26px rgba(0, 0, 0, 0.3);
    }

    & > .lfc-head {
        background: rgba(0, 0, 0, 0.22);
        border-bottom: 1px solid #38495a;
        ${tw`p-4 text-center`};
    }

    & > .lfc-body {
        ${tw`p-5`};
    }

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
        <FlashMessageRender css={tw`mb-2 px-1`} />
        <Form {...props} ref={ref}>
            <Card>
                {title && (
                    <div className={'lfc-head'}>
                        <h2 css={tw`text-lg text-neutral-100 font-medium`}>{title}</h2>
                        <p css={tw`text-xs text-neutral-400 mt-1`}>Sign in to manage your servers</p>
                    </div>
                )}
                <div className={'lfc-body'}>
                    <div css={tw`w-full`}>{props.children}</div>
                </div>
            </Card>
        </Form>
        <p css={tw`text-center text-neutral-500 text-xs mt-3`}>
            &copy; 2015 - {new Date().getFullYear()}&nbsp;KeztraviaMC
        </p>
    </Container>
));
