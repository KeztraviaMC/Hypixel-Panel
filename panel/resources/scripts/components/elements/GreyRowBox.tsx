import styled from 'styled-components/macro';
import tw from 'twin.macro';

export default styled.div<{ $hoverable?: boolean }>`
    background: linear-gradient(150deg, #2b3644 0%, #212a35 100%);
    border: 1px solid #38495a;
    box-shadow: 0 6px 18px rgba(0, 0, 0, 0.2);
    ${tw`flex rounded-lg no-underline text-neutral-200 items-center p-4 transition-all duration-150 overflow-hidden`};

    ${(props) =>
        props.$hoverable !== false &&
        `&:hover { border-color: #4a90bf; box-shadow: 0 10px 26px rgba(0,0,0,.3); }`};

    & .icon {
        ${tw`rounded-lg w-16 flex items-center justify-center p-3`};
        background: #203d52;
        border: 1px solid #356985;
        color: #67b7e5;
    }
`;
